use crate::output::OutputAssignment;
use std::collections::HashMap;

pub fn night_shift_distribution_penalty(assignments: &[OutputAssignment]) -> i64 {
    let mut counts: HashMap<&str, i64> = HashMap::new();
    for assignment in assignments {
        if assignment.starts_at.contains("T00:") || assignment.starts_at.contains("T23:") {
            *counts.entry(assignment.employee_id.as_str()).or_default() += 1;
        }
    }

    if counts.is_empty() {
        return 0;
    }

    let max = counts.values().max().copied().unwrap_or(0);
    let min = counts.values().min().copied().unwrap_or(0);
    (max - min) * 2
}

