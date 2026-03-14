#[cfg(feature = "cp_sat_backend")]
use hospital_scheduling_solver::solve;
use hospital_scheduling_solver::{ContractHarnessBackend, InputSnapshot, solve_with_backend};

#[test]
fn previous_version_seed_is_retained_as_copied_assignment() {
    let snapshot: InputSnapshot =
        serde_json::from_str(include_str!("../fixtures/previous_version_snapshot.json")).unwrap();

    let result = solve_with_backend(&snapshot, &ContractHarnessBackend).unwrap();

    assert!(
        result
            .assignments
            .iter()
            .any(|item| item.requirement_id == "req-night-1"
                && item.employee_id == "emp-1"
                && matches!(
                    item.source,
                    hospital_scheduling_solver::model::AssignmentSource::Copied
                ))
    );
}

#[cfg(feature = "cp_sat_backend")]
#[test]
fn cp_sat_previous_version_seed_is_retained_as_copied_assignment() {
    let snapshot: InputSnapshot =
        serde_json::from_str(include_str!("../fixtures/previous_version_snapshot.json")).unwrap();

    let result = solve(&snapshot).unwrap();

    assert!(
        result
            .assignments
            .iter()
            .any(|item| item.requirement_id == "req-night-1"
                && item.employee_id == "emp-1"
                && matches!(
                    item.source,
                    hospital_scheduling_solver::model::AssignmentSource::Copied
                ))
    );
}
