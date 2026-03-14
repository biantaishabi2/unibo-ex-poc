use crate::model::RunMode;
use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InputSnapshot {
    pub period: PeriodSnapshot,
    #[serde(default)]
    pub requirements: Vec<RequirementSnapshot>,
    #[serde(default)]
    pub constraints: Vec<ConstraintSnapshot>,
    #[serde(default)]
    pub employees: Vec<EmployeeSnapshot>,
    #[serde(default)]
    pub preferences: Vec<ShiftPreferenceSnapshot>,
    #[serde(default)]
    pub medical_staff_profiles: Vec<MedicalStaffProfileSnapshot>,
    #[serde(default)]
    pub skills: Vec<EmployeeSkillsSnapshot>,
    #[serde(default)]
    pub leaves: Vec<LeaveSnapshot>,
    pub calendar: Option<CalendarSnapshot>,
    #[serde(default)]
    pub locked_assignments: Vec<SeedAssignmentSnapshot>,
    #[serde(default)]
    pub previous_version_assignments: Vec<SeedAssignmentSnapshot>,
    pub run_options: RunOptionsSnapshot,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeriodSnapshot {
    pub id: String,
    pub department_id: String,
    pub start_date: String,
    pub end_date: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RequirementSnapshot {
    pub id: String,
    pub date: String,
    pub shift_type_id: String,
    pub role_code: String,
    #[serde(default)]
    pub required_skill_tags: Vec<String>,
    pub min_headcount: usize,
    #[serde(default)]
    pub target_headcount: Option<usize>,
    #[serde(default)]
    pub required_lead_count: usize,
    #[serde(default = "default_priority")]
    pub priority: usize,
    pub starts_at: String,
    pub ends_at: String,
}

fn default_priority() -> usize {
    100
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConstraintSnapshot {
    pub id: String,
    pub constraint_type: String,
    pub category: String,
    #[serde(default)]
    pub params: Value,
    #[serde(default)]
    pub weight: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EmployeeSnapshot {
    pub id: String,
    pub employee_code: String,
    #[serde(default)]
    pub name: Option<String>,
    #[serde(default)]
    pub hire_date: Option<String>,
    #[serde(default)]
    pub department_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ShiftPreferenceSnapshot {
    pub employee_id: String,
    #[serde(default)]
    pub preferred_shift_tags: Vec<String>,
    #[serde(default)]
    pub unavailable_dates: Vec<String>,
    #[serde(default)]
    pub max_night_shifts: Option<usize>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MedicalStaffProfileSnapshot {
    pub employee_id: String,
    #[serde(default)]
    pub maturity_score: f64,
    #[serde(default)]
    pub can_lead_shift: bool,
    #[serde(default)]
    pub work_restrictions: Vec<String>,
    #[serde(default)]
    pub overtime_willing: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EmployeeSkillsSnapshot {
    pub employee_id: String,
    #[serde(default)]
    pub skill_tags: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LeaveSnapshot {
    pub employee_id: String,
    pub starts_at: String,
    pub ends_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CalendarSnapshot {
    pub work_schedule: Option<WorkScheduleSnapshot>,
    #[serde(default)]
    pub exceptions: Vec<CalendarExceptionSnapshot>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorkScheduleSnapshot {
    pub id: String,
    pub timezone: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CalendarExceptionSnapshot {
    pub date: String,
    pub exception_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeedAssignmentSnapshot {
    pub employee_id: String,
    pub requirement_id: String,
    pub starts_at: String,
    pub ends_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RunOptionsSnapshot {
    pub mode: RunMode,
    #[serde(default)]
    pub seed: Option<u64>,
    #[serde(default = "default_timeout_ms")]
    pub timeout_ms: u64,
    #[serde(default = "default_engine")]
    pub engine_type: String,
}

fn default_timeout_ms() -> u64 {
    30_000
}

fn default_engine() -> String {
    "cp_sat".to_string()
}
