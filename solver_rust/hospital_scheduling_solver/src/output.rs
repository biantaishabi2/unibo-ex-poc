use crate::model::{AssignmentSource, Severity, SolverStatus};
use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OutputSnapshot {
    pub status: SolverStatus,
    pub summary: SummarySnapshot,
    #[serde(default)]
    pub assignments: Vec<OutputAssignment>,
    #[serde(default)]
    pub coverage: Vec<CoverageSummary>,
    #[serde(default)]
    pub violations: Vec<ViolationSummary>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SummarySnapshot {
    pub phase: String,
    pub requirement_count: usize,
    pub covered_requirement_count: usize,
    pub assignment_count: usize,
    pub error_count: usize,
    pub warning_count: usize,
    pub score: i64,
    pub seed: Option<u64>,
    pub duration_ms: u64,
    pub engine_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OutputAssignment {
    pub requirement_id: String,
    pub employee_id: String,
    pub starts_at: String,
    pub ends_at: String,
    pub source: AssignmentSource,
    pub locked: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoverageSummary {
    pub requirement_id: String,
    pub required: usize,
    pub assigned: usize,
    pub missing: usize,
    pub lead_required: usize,
    pub lead_assigned: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ViolationSummary {
    pub rule_code: String,
    pub severity: Severity,
    pub requirement_id: Option<String>,
    pub assignment_id: Option<String>,
    pub message: String,
    pub details: Value,
}

