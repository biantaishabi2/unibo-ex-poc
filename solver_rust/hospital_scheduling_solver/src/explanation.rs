use crate::model::Severity;
use crate::output::ViolationSummary;
use serde_json::json;

pub fn requirement_violation(
    rule_code: &str,
    severity: Severity,
    requirement_id: &str,
    message: &str,
    actual: usize,
    expected: usize,
) -> ViolationSummary {
    ViolationSummary {
        rule_code: rule_code.to_string(),
        severity,
        requirement_id: Some(requirement_id.to_string()),
        assignment_id: None,
        message: message.to_string(),
        details: json!({
            "source_level": "requirement",
            "actual": actual,
            "expected": expected,
            "related_ids": [requirement_id]
        }),
    }
}

pub fn assignment_violation(
    rule_code: &str,
    severity: Severity,
    requirement_id: &str,
    assignment_id: &str,
    message: &str,
) -> ViolationSummary {
    ViolationSummary {
        rule_code: rule_code.to_string(),
        severity,
        requirement_id: Some(requirement_id.to_string()),
        assignment_id: Some(assignment_id.to_string()),
        message: message.to_string(),
        details: json!({
            "source_level": "assignment",
            "related_ids": [requirement_id, assignment_id]
        }),
    }
}
