use crate::snapshot::{EmployeeSkillsSnapshot, LeaveSnapshot, MedicalStaffProfileSnapshot, RequirementSnapshot};

pub fn employee_is_on_leave(leaves: &[LeaveSnapshot], employee_id: &str, starts_at: &str, ends_at: &str) -> bool {
    leaves.iter().any(|leave| {
        leave.employee_id == employee_id
            && !(leave.ends_at.as_str() < starts_at || leave.starts_at.as_str() > ends_at)
    })
}

pub fn employee_has_required_skills(
    skills: &[EmployeeSkillsSnapshot],
    employee_id: &str,
    requirement: &RequirementSnapshot,
) -> bool {
    if requirement.required_skill_tags.is_empty() {
        return true;
    }

    skills
        .iter()
        .find(|item| item.employee_id == employee_id)
        .map(|item| {
            requirement
                .required_skill_tags
                .iter()
                .all(|tag| item.skill_tags.iter().any(|skill| skill == tag))
        })
        .unwrap_or(false)
}

pub fn employee_can_lead(
    profiles: &[MedicalStaffProfileSnapshot],
    employee_id: &str,
) -> bool {
    profiles
        .iter()
        .find(|item| item.employee_id == employee_id)
        .map(|item| item.can_lead_shift)
        .unwrap_or(false)
}

pub fn employee_has_work_restriction(
    profiles: &[MedicalStaffProfileSnapshot],
    employee_id: &str,
    restriction: &str,
) -> bool {
    profiles
        .iter()
        .find(|item| item.employee_id == employee_id)
        .map(|item| item.work_restrictions.iter().any(|item| item == restriction))
        .unwrap_or(false)
}

