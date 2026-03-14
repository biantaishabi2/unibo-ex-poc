use hospital_scheduling_solver::{InputSnapshot, solve};

#[test]
fn blank_mode_generates_assignments_and_summary() {
    let snapshot: InputSnapshot =
        serde_json::from_str(include_str!("../fixtures/blank_snapshot.json")).unwrap();

    let result = solve(&snapshot).unwrap();

    assert_eq!(result.summary.requirement_count, 2);
    assert_eq!(result.summary.covered_requirement_count, 2);
    assert_eq!(result.assignments.len(), 2);
    assert!(matches!(
        result.status,
        hospital_scheduling_solver::model::SolverStatus::Completed
            | hospital_scheduling_solver::model::SolverStatus::Feasible
    ));
}

