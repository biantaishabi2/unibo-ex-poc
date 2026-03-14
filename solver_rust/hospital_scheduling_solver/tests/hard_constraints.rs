use hospital_scheduling_solver::{InputSnapshot, solve};
use hospital_scheduling_solver::model::Severity;

#[test]
fn leave_conflict_is_reported_as_error_violation() {
    let snapshot: InputSnapshot =
        serde_json::from_str(include_str!("../fixtures/leave_conflict_snapshot.json")).unwrap();

    let result = solve(&snapshot).unwrap();

    assert!(result
        .violations
        .iter()
        .any(|item| item.rule_code == "coverage_missing" && item.severity == Severity::Error));
}

