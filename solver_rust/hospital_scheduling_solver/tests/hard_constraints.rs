use hospital_scheduling_solver::model::Severity;
#[cfg(feature = "cp_sat_backend")]
use hospital_scheduling_solver::solve;
use hospital_scheduling_solver::{ContractHarnessBackend, InputSnapshot, solve_with_backend};

#[test]
fn leave_conflict_is_reported_as_error_violation() {
    let snapshot: InputSnapshot =
        serde_json::from_str(include_str!("../fixtures/leave_conflict_snapshot.json")).unwrap();

    let result = solve_with_backend(&snapshot, &ContractHarnessBackend).unwrap();

    assert!(
        result
            .violations
            .iter()
            .any(|item| item.rule_code == "coverage_missing" && item.severity == Severity::Error)
    );
}

#[cfg(feature = "cp_sat_backend")]
#[test]
fn cp_sat_leave_conflict_is_reported_as_error_violation() {
    let snapshot: InputSnapshot =
        serde_json::from_str(include_str!("../fixtures/leave_conflict_snapshot.json")).unwrap();

    let result = solve(&snapshot).unwrap();

    assert!(
        result
            .violations
            .iter()
            .any(|item| item.rule_code == "coverage_missing" && item.severity == Severity::Error)
    );
}
