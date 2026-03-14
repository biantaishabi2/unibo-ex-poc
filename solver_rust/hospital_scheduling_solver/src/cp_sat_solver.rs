use std::collections::{HashMap, HashSet};
use std::time::Instant;

use cp_sat::builder::{BoolVar, CpModelBuilder, IntVar, LinearExpr};
use cp_sat::proto::{CpSolverResponse, CpSolverStatus, SatParameters};

use crate::model::{AssignmentSource, RunMode};
use crate::output::{OutputAssignment, OutputSnapshot};
use crate::rules::hard;
use crate::snapshot::{InputSnapshot, RequirementSnapshot, SeedAssignmentSnapshot};
use crate::solver::{SolveError, finalize_output};

const ASSIGNMENT_REWARD: i64 = 100;
const PREVIOUS_VERSION_REWARD: i64 = 25;

#[derive(Debug, Clone)]
struct CandidateAssignment {
    requirement_id: String,
    employee_id: String,
    starts_at: String,
    ends_at: String,
    var: BoolVar,
    locked: bool,
    from_previous_version: bool,
    can_lead: bool,
    has_required_skills: bool,
}

pub fn solve(snapshot: &InputSnapshot) -> Result<OutputSnapshot, SolveError> {
    if snapshot.requirements.is_empty() {
        return Err(SolveError::EmptyRequirements);
    }

    let started = Instant::now();
    let locked_pairs = assignment_pair_keys(&snapshot.locked_assignments);
    let previous_pairs = assignment_pair_keys(&snapshot.previous_version_assignments);

    let mut model = CpModelBuilder::default();
    let candidates = build_candidates(snapshot, &mut model, &locked_pairs, &previous_pairs);

    add_requirement_constraints(snapshot, &mut model, &candidates);
    add_overlap_constraints(&mut model, &candidates);
    add_locked_assignment_constraints(&mut model, &candidates);
    add_previous_version_hints(snapshot, &mut model, &candidates);
    add_objective(&mut model, &candidates);

    let validation_error = model.validate_cp_model();
    if !validation_error.is_empty() {
        return Err(SolveError::BackendUnavailable {
            backend: "cp_sat".to_string(),
            reason: format!("CP-SAT model validation failed: {validation_error}"),
        });
    }

    let response = model.solve_with_parameters(&solver_parameters(snapshot));
    let assignments = match response.status() {
        CpSolverStatus::Optimal | CpSolverStatus::Feasible => {
            extract_assignments(&response, &candidates)
        }
        CpSolverStatus::Infeasible => Vec::new(),
        status => {
            return Err(SolveError::BackendUnavailable {
                backend: "cp_sat".to_string(),
                reason: format!("CP-SAT returned unexpected status: {status:?}"),
            });
        }
    };

    Ok(finalize_output(
        snapshot,
        assignments,
        "cp_sat_emit_result",
        started,
        "cp_sat".to_string(),
    ))
}

fn assignment_pair_keys(assignments: &[SeedAssignmentSnapshot]) -> HashSet<(String, String)> {
    assignments
        .iter()
        .map(|item| (item.requirement_id.clone(), item.employee_id.clone()))
        .collect()
}

fn build_candidates(
    snapshot: &InputSnapshot,
    model: &mut CpModelBuilder,
    locked_pairs: &HashSet<(String, String)>,
    previous_pairs: &HashSet<(String, String)>,
) -> Vec<CandidateAssignment> {
    let mut candidates = Vec::new();

    for requirement in &snapshot.requirements {
        for employee in &snapshot.employees {
            let pair = (requirement.id.clone(), employee.id.clone());
            let locked = locked_pairs.contains(&pair);
            let from_previous_version = snapshot.run_options.mode
                == RunMode::SolveFromPreviousVersion
                && previous_pairs.contains(&pair);
            let can_lead = hard::employee_can_lead(&snapshot.medical_staff_profiles, &employee.id);
            let has_required_skills =
                hard::employee_has_required_skills(&snapshot.skills, &employee.id, requirement);
            let leave_conflict = hard::employee_is_on_leave(
                &snapshot.leaves,
                &employee.id,
                &requirement.starts_at,
                &requirement.ends_at,
            );
            let restricted_night = hard::employee_has_work_restriction(
                &snapshot.medical_staff_profiles,
                &employee.id,
                "pregnant",
            ) && is_night_shift(requirement);

            if !(has_required_skills && !leave_conflict && !restricted_night) && !locked {
                continue;
            }

            let var = model
                .new_bool_var_with_name(format!("assign__{}__{}", requirement.id, employee.id));

            candidates.push(CandidateAssignment {
                requirement_id: requirement.id.clone(),
                employee_id: employee.id.clone(),
                starts_at: requirement.starts_at.clone(),
                ends_at: requirement.ends_at.clone(),
                var,
                locked,
                from_previous_version,
                can_lead,
                has_required_skills,
            });
        }
    }

    candidates
}

fn add_requirement_constraints(
    snapshot: &InputSnapshot,
    model: &mut CpModelBuilder,
    candidates: &[CandidateAssignment],
) {
    for requirement in &snapshot.requirements {
        let requirement_candidates: Vec<&CandidateAssignment> = candidates
            .iter()
            .filter(|item| item.requirement_id == requirement.id)
            .collect();
        let upper = requirement
            .target_headcount
            .unwrap_or(requirement.min_headcount)
            .max(requirement.min_headcount) as i64;
        let assigned_terms: Vec<(i64, IntVar)> = requirement_candidates
            .iter()
            .map(|item| (1_i64, item.var.into()))
            .collect();

        if assigned_terms.len() < requirement.min_headcount {
            add_impossible_constraint(model, format!("coverage_gap__{}", requirement.id));
        } else {
            model.add_linear_constraint(
                linear_expr(&assigned_terms),
                [(requirement.min_headcount as i64, upper)],
            );
        }

        if requirement.required_lead_count > 0 {
            let lead_terms: Vec<(i64, IntVar)> = requirement_candidates
                .iter()
                .filter(|item| item.can_lead)
                .map(|item| (1_i64, item.var.into()))
                .collect();

            if lead_terms.len() < requirement.required_lead_count {
                add_impossible_constraint(model, format!("lead_gap__{}", requirement.id));
            } else {
                model.add_ge(
                    linear_expr(&lead_terms),
                    requirement.required_lead_count as i64,
                );
            }
        }

        if !requirement.required_skill_tags.is_empty() {
            let skill_terms: Vec<(i64, IntVar)> = requirement_candidates
                .iter()
                .filter(|item| item.has_required_skills)
                .map(|item| (1_i64, item.var.into()))
                .collect();

            if skill_terms.len() < requirement.min_headcount {
                add_impossible_constraint(model, format!("skill_gap__{}", requirement.id));
            } else {
                model.add_ge(linear_expr(&skill_terms), requirement.min_headcount as i64);
            }
        }
    }
}

fn add_overlap_constraints(model: &mut CpModelBuilder, candidates: &[CandidateAssignment]) {
    let mut by_employee: HashMap<&str, Vec<&CandidateAssignment>> = HashMap::new();
    for candidate in candidates {
        by_employee
            .entry(candidate.employee_id.as_str())
            .or_default()
            .push(candidate);
    }

    for employee_candidates in by_employee.into_values() {
        for (index, left) in employee_candidates.iter().enumerate() {
            for right in employee_candidates.iter().skip(index + 1) {
                if slots_overlap(left, right) {
                    model.add_at_most_one([left.var, right.var]);
                }
            }
        }
    }
}

fn add_locked_assignment_constraints(
    model: &mut CpModelBuilder,
    candidates: &[CandidateAssignment],
) {
    for candidate in candidates.iter().filter(|item| item.locked) {
        model.add_eq(candidate.var, 1);
    }
}

fn add_previous_version_hints(
    snapshot: &InputSnapshot,
    model: &mut CpModelBuilder,
    candidates: &[CandidateAssignment],
) {
    if snapshot.run_options.mode != RunMode::SolveFromPreviousVersion {
        return;
    }

    for candidate in candidates.iter().filter(|item| item.from_previous_version) {
        model.add_hint(candidate.var, 1);
    }
}

fn add_objective(model: &mut CpModelBuilder, candidates: &[CandidateAssignment]) {
    let mut objective_terms: Vec<(i64, IntVar)> = Vec::new();

    for candidate in candidates {
        objective_terms.push((ASSIGNMENT_REWARD, candidate.var.into()));
        if candidate.from_previous_version {
            objective_terms.push((PREVIOUS_VERSION_REWARD, candidate.var.into()));
        }
    }

    model.maximize(linear_expr(&objective_terms));
}

fn solver_parameters(snapshot: &InputSnapshot) -> SatParameters {
    SatParameters {
        max_time_in_seconds: Some(snapshot.run_options.timeout_ms as f64 / 1000.0),
        num_search_workers: Some(1),
        use_optimization_hints: Some(true),
        repair_hint: Some(snapshot.run_options.mode == RunMode::SolveFromPreviousVersion),
        random_seed: snapshot.run_options.seed.map(|seed| seed as i32),
        ..Default::default()
    }
}

fn extract_assignments(
    response: &CpSolverResponse,
    candidates: &[CandidateAssignment],
) -> Vec<OutputAssignment> {
    candidates
        .iter()
        .filter(|item| item.var.solution_value(response))
        .map(|item| OutputAssignment {
            requirement_id: item.requirement_id.clone(),
            employee_id: item.employee_id.clone(),
            starts_at: item.starts_at.clone(),
            ends_at: item.ends_at.clone(),
            source: if item.locked || item.from_previous_version {
                AssignmentSource::Copied
            } else {
                AssignmentSource::Auto
            },
            locked: item.locked,
        })
        .collect()
}

fn slots_overlap(left: &CandidateAssignment, right: &CandidateAssignment) -> bool {
    !(left.ends_at <= right.starts_at || right.ends_at <= left.starts_at)
}

fn is_night_shift(requirement: &RequirementSnapshot) -> bool {
    requirement.starts_at.contains("T00:") || requirement.starts_at.contains("T23:")
}

fn linear_expr(terms: &[(i64, IntVar)]) -> LinearExpr {
    terms.iter().copied().collect::<LinearExpr>()
}

fn add_impossible_constraint(model: &mut CpModelBuilder, name: String) {
    let impossible = model.new_bool_var_with_name(name);
    model.add_eq(impossible, 0);
    model.add_eq(impossible, 1);
}
