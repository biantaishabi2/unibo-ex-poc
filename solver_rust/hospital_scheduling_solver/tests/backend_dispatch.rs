use hospital_scheduling_solver::{InputSnapshot, solve};

#[test]
fn cp_sat_engine_reports_backend_unavailable_for_now() {
    let mut snapshot: InputSnapshot =
        serde_json::from_str(include_str!("../fixtures/blank_snapshot.json")).unwrap();
    snapshot.run_options.engine_type = "cp_sat".to_string();

    let error =
        solve(&snapshot).expect_err("cp_sat backend should not be silently routed to harness");

    assert!(error.to_string().contains("backend `cp_sat` unavailable"));
}
