//! 当前文件只承担 contract harness / fixture runner 角色。
//! 它用于冻结输入输出结构、状态语义和 explanation 输出，
//! 不是 #69 最终求解器实现。

use std::collections::{HashMap, HashSet};
use std::time::Instant;

use crate::backend;
use crate::explanation::{assignment_violation, requirement_violation};
use crate::model::{AssignmentSource, RunMode, Severity, SolverStatus};
use crate::output::{
    CoverageSummary, OutputAssignment, OutputSnapshot, SummarySnapshot, ViolationSummary,
};
use crate::rules::{hard, soft};
use crate::score::compute_score;
use crate::snapshot::{InputSnapshot, RequirementSnapshot, SeedAssignmentSnapshot};
use thiserror::Error;

#[derive(Debug, Error)]
pub enum SolveError {
    #[error("snapshot has no requirements")]
    EmptyRequirements,
    #[error("unsupported engine_type: {engine_type}")]
    UnsupportedEngine { engine_type: String },
    #[error("backend `{backend}` unavailable: {reason}")]
    BackendUnavailable { backend: String, reason: String },
}

#[derive(Debug, Clone)]
struct WorkingState {
    assignments: Vec<OutputAssignment>,
    assignment_keys: HashSet<(String, String, String)>,
}

pub fn solve(snapshot: &InputSnapshot) -> Result<OutputSnapshot, SolveError> {
    backend::solve_with_engine(snapshot)
}

pub(crate) fn contract_harness_solve(
    snapshot: &InputSnapshot,
) -> Result<OutputSnapshot, SolveError> {
    if snapshot.requirements.is_empty() {
        return Err(SolveError::EmptyRequirements);
    }

    let started = Instant::now();
    let mut state = load_snapshot();
    seed_initial_solution(snapshot, &mut state);
    let mut violations = repair_hard_constraints(snapshot, &state);
    improve_soft_score(&mut violations, &state);

    let coverage = build_coverage(snapshot, &state.assignments);
    let error_count = violations
        .iter()
        .filter(|item| item.severity == Severity::Error)
        .count();
    let warning_count = violations
        .iter()
        .filter(|item| item.severity == Severity::Warning)
        .count();
    let covered_requirement_count = coverage.iter().filter(|item| item.missing == 0).count();
    let score = compute_score(&coverage, &violations)
        - soft::night_shift_distribution_penalty(&state.assignments);

    let status = if error_count == 0 {
        SolverStatus::Completed
    } else if covered_requirement_count > 0 {
        SolverStatus::Feasible
    } else {
        SolverStatus::Infeasible
    };

    Ok(OutputSnapshot {
        status,
        summary: SummarySnapshot {
            phase: "emit_result".to_string(),
            requirement_count: snapshot.requirements.len(),
            covered_requirement_count,
            assignment_count: state.assignments.len(),
            error_count,
            warning_count,
            score,
            seed: snapshot.run_options.seed,
            duration_ms: started.elapsed().as_millis() as u64,
            engine_type: snapshot.run_options.engine_type.clone(),
        },
        assignments: state.assignments,
        coverage,
        violations,
    })
}

fn load_snapshot() -> WorkingState {
    WorkingState {
        assignments: Vec::new(),
        assignment_keys: HashSet::new(),
    }
}

fn seed_initial_solution(snapshot: &InputSnapshot, state: &mut WorkingState) {
    if snapshot.run_options.mode == RunMode::SolveFromPreviousVersion {
        for seed in &snapshot.previous_version_assignments {
            push_seed_assignment(state, seed, AssignmentSource::Copied, false);
        }
    }

    for locked in &snapshot.locked_assignments {
        push_seed_assignment(state, locked, AssignmentSource::Copied, true);
    }

    let sorted_requirements = sorted_requirements(&snapshot.requirements);
    for requirement in sorted_requirements {
        let existing = state
            .assignments
            .iter()
            .filter(|item| item.requirement_id == requirement.id)
            .count();
        if existing >= requirement.min_headcount {
            continue;
        }

        for employee in &snapshot.employees {
            if state
                .assignments
                .iter()
                .filter(|item| item.requirement_id == requirement.id)
                .count()
                >= requirement.min_headcount
            {
                break;
            }

            let duplicate_key = (
                snapshot.period.id.clone(),
                employee.id.clone(),
                requirement.starts_at.clone(),
            );
            if state.assignment_keys.contains(&duplicate_key) {
                continue;
            }

            if hard::employee_is_on_leave(
                &snapshot.leaves,
                &employee.id,
                &requirement.starts_at,
                &requirement.ends_at,
            ) {
                continue;
            }

            if hard::employee_has_work_restriction(
                &snapshot.medical_staff_profiles,
                &employee.id,
                "pregnant",
            ) && is_night_shift(requirement)
            {
                continue;
            }

            if !hard::employee_has_required_skills(&snapshot.skills, &employee.id, requirement) {
                continue;
            }

            state.assignment_keys.insert(duplicate_key);
            state.assignments.push(OutputAssignment {
                requirement_id: requirement.id.clone(),
                employee_id: employee.id.clone(),
                starts_at: requirement.starts_at.clone(),
                ends_at: requirement.ends_at.clone(),
                source: AssignmentSource::Auto,
                locked: false,
            });
        }
    }
}

fn repair_hard_constraints(
    snapshot: &InputSnapshot,
    state: &WorkingState,
) -> Vec<ViolationSummary> {
    let mut violations = Vec::new();

    for requirement in &snapshot.requirements {
        let assignments: Vec<&OutputAssignment> = state
            .assignments
            .iter()
            .filter(|item| item.requirement_id == requirement.id)
            .collect();
        let assigned = assignments.len();
        let lead_assigned = assignments
            .iter()
            .filter(|item| {
                hard::employee_can_lead(&snapshot.medical_staff_profiles, &item.employee_id)
            })
            .count();

        if assigned < requirement.min_headcount {
            violations.push(requirement_violation(
                "coverage_missing",
                Severity::Error,
                &requirement.id,
                "排班人数不足",
                assigned,
                requirement.min_headcount,
            ));
        }

        if lead_assigned < requirement.required_lead_count {
            violations.push(requirement_violation(
                "lead_coverage",
                Severity::Error,
                &requirement.id,
                "缺少带班护士",
                lead_assigned,
                requirement.required_lead_count,
            ));
        }

        if !requirement.required_skill_tags.is_empty() {
            let skill_matched = assignments
                .iter()
                .filter(|item| {
                    hard::employee_has_required_skills(
                        &snapshot.skills,
                        &item.employee_id,
                        requirement,
                    )
                })
                .count();
            if skill_matched < requirement.min_headcount {
                violations.push(requirement_violation(
                    "skill_requirement",
                    Severity::Error,
                    &requirement.id,
                    "技能覆盖不足",
                    skill_matched,
                    requirement.min_headcount,
                ));
            }
        }
    }

    let requirement_by_id: HashMap<&str, &RequirementSnapshot> = snapshot
        .requirements
        .iter()
        .map(|item| (item.id.as_str(), item))
        .collect();

    for (index, assignment) in state.assignments.iter().enumerate() {
        let assignment_id = format!("assignment-{}", index);
        let Some(requirement) = requirement_by_id.get(assignment.requirement_id.as_str()) else {
            continue;
        };

        if hard::employee_is_on_leave(
            &snapshot.leaves,
            &assignment.employee_id,
            &assignment.starts_at,
            &assignment.ends_at,
        ) {
            violations.push(assignment_violation(
                "respect_leave",
                Severity::Error,
                &assignment.requirement_id,
                &assignment_id,
                "排班与请假时间冲突",
            ));
        }

        if hard::employee_has_work_restriction(
            &snapshot.medical_staff_profiles,
            &assignment.employee_id,
            "pregnant",
        ) && is_night_shift(requirement)
        {
            violations.push(assignment_violation(
                "work_restriction",
                Severity::Error,
                &assignment.requirement_id,
                &assignment_id,
                "孕期或限制状态下不允许夜班",
            ));
        }
    }

    violations
}

fn improve_soft_score(violations: &mut Vec<ViolationSummary>, state: &WorkingState) {
    let distribution_penalty = soft::night_shift_distribution_penalty(&state.assignments);
    if distribution_penalty > 0 {
        violations.push(ViolationSummary {
            rule_code: "fair_night_distribution".to_string(),
            severity: Severity::Warning,
            requirement_id: None,
            assignment_id: None,
            message: "夜班分配仍然不够均衡".to_string(),
            details: serde_json::json!({
                "source_level": "run",
                "penalty": distribution_penalty
            }),
        });
    }
}

fn build_coverage(
    snapshot: &InputSnapshot,
    assignments: &[OutputAssignment],
) -> Vec<CoverageSummary> {
    snapshot
        .requirements
        .iter()
        .map(|requirement| {
            let assigned: Vec<&OutputAssignment> = assignments
                .iter()
                .filter(|item| item.requirement_id == requirement.id)
                .collect();
            let assigned_count = assigned.len();
            let lead_assigned = assigned
                .iter()
                .filter(|item| {
                    hard::employee_can_lead(&snapshot.medical_staff_profiles, &item.employee_id)
                })
                .count();
            CoverageSummary {
                requirement_id: requirement.id.clone(),
                required: requirement.min_headcount,
                assigned: assigned_count,
                missing: requirement.min_headcount.saturating_sub(assigned_count),
                lead_required: requirement.required_lead_count,
                lead_assigned,
            }
        })
        .collect()
}

fn push_seed_assignment(
    state: &mut WorkingState,
    seed: &SeedAssignmentSnapshot,
    source: AssignmentSource,
    locked: bool,
) {
    // seed assignment 也使用同一套去重键，避免后续填充阶段重复塞入相同时段。
    let key = (
        "period".to_string(),
        seed.employee_id.clone(),
        seed.starts_at.clone(),
    );
    if state.assignment_keys.insert(key) {
        state.assignments.push(OutputAssignment {
            requirement_id: seed.requirement_id.clone(),
            employee_id: seed.employee_id.clone(),
            starts_at: seed.starts_at.clone(),
            ends_at: seed.ends_at.clone(),
            source,
            locked,
        });
    }
}

fn sorted_requirements(requirements: &[RequirementSnapshot]) -> Vec<&RequirementSnapshot> {
    let mut items: Vec<&RequirementSnapshot> = requirements.iter().collect();
    items.sort_by(|left, right| {
        left.priority
            .cmp(&right.priority)
            .then_with(|| left.date.cmp(&right.date))
            .then_with(|| left.starts_at.cmp(&right.starts_at))
    });
    items
}

fn is_night_shift(requirement: &RequirementSnapshot) -> bool {
    requirement.starts_at.contains("T00:") || requirement.starts_at.contains("T23:")
}
