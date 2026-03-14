use hospital_scheduling_solver::{InputSnapshot, solve};

#[test]
fn output_snapshot_contains_structured_explanations() {
    let snapshot: InputSnapshot =
        serde_json::from_str(include_str!("../fixtures/lead_gap_snapshot.json")).unwrap();

    let result = solve(&snapshot).unwrap();

    let lead_gap = result
        .violations
        .iter()
        .find(|item| item.rule_code == "lead_coverage")
        .expect("expected lead coverage violation");

    assert_eq!(lead_gap.details["source_level"], "requirement");
    assert_eq!(lead_gap.details["expected"], 1);
}

