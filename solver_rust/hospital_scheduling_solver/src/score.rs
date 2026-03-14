use crate::output::{CoverageSummary, ViolationSummary};
use crate::model::Severity;

pub fn compute_score(coverage: &[CoverageSummary], violations: &[ViolationSummary]) -> i64 {
    let coverage_score: i64 = coverage
        .iter()
        .map(|item| ((item.assigned as i64) * 10) - ((item.missing as i64) * 20))
        .sum();
    let warning_penalty = violations
        .iter()
        .filter(|item| item.severity == Severity::Warning)
        .count() as i64
        * 5;
    let error_penalty = violations
        .iter()
        .filter(|item| item.severity == Severity::Error)
        .count() as i64
        * 100;

    coverage_score - warning_penalty - error_penalty
}

