#[cfg(feature = "cp_sat_backend")]
use crate::cp_sat_solver;
use crate::output::OutputSnapshot;
use crate::snapshot::InputSnapshot;
use crate::solver::{SolveError, contract_harness_solve};

/// 统一收口 solver backend 边界，避免把当前 contract harness 误认为最终求解器。
pub trait SchedulingSolverBackend {
    fn engine_type(&self) -> &'static str;
    fn solve(&self, snapshot: &InputSnapshot) -> Result<OutputSnapshot, SolveError>;
}

#[derive(Debug, Default, Clone, Copy)]
pub struct ContractHarnessBackend;

impl SchedulingSolverBackend for ContractHarnessBackend {
    fn engine_type(&self) -> &'static str {
        "contract_harness"
    }

    fn solve(&self, snapshot: &InputSnapshot) -> Result<OutputSnapshot, SolveError> {
        contract_harness_solve(snapshot)
    }
}

#[derive(Debug, Default, Clone, Copy)]
pub struct CpSatBackend;

impl SchedulingSolverBackend for CpSatBackend {
    fn engine_type(&self) -> &'static str {
        "cp_sat"
    }

    fn solve(&self, snapshot: &InputSnapshot) -> Result<OutputSnapshot, SolveError> {
        cp_sat_solve(snapshot)
    }
}

pub fn solve_with_backend(
    snapshot: &InputSnapshot,
    backend: &dyn SchedulingSolverBackend,
) -> Result<OutputSnapshot, SolveError> {
    backend.solve(snapshot)
}

pub fn solve_with_engine(snapshot: &InputSnapshot) -> Result<OutputSnapshot, SolveError> {
    match snapshot.run_options.engine_type.as_str() {
        "contract_harness" | "rust_contract_harness" => {
            solve_with_backend(snapshot, &ContractHarnessBackend)
        }
        // 向后兼容 #68 合并时遗留的默认值，但统一收口到 CP-SAT。
        "cp_sat" | "rust_cp_sat" | "greedy_local_search" | "rust_greedy_local_search" => {
            solve_with_backend(snapshot, &CpSatBackend)
        }
        engine_type => Err(SolveError::UnsupportedEngine {
            engine_type: engine_type.to_string(),
        }),
    }
}

#[cfg(feature = "cp_sat_backend")]
fn cp_sat_solve(snapshot: &InputSnapshot) -> Result<OutputSnapshot, SolveError> {
    cp_sat_solver::solve(snapshot)
}

#[cfg(not(feature = "cp_sat_backend"))]
fn cp_sat_solve(_snapshot: &InputSnapshot) -> Result<OutputSnapshot, SolveError> {
    Err(SolveError::BackendUnavailable {
        backend: "cp_sat".to_string(),
        reason: "CP-SAT backend 尚未接入 OR-Tools/runtime；当前 crate 只冻结契约与 adapter 边界"
            .to_string(),
    })
}

#[cfg(all(test, feature = "cp_sat_backend"))]
mod tests {
    use cp_sat::builder::CpModelBuilder;
    use cp_sat::proto::CpSolverStatus;

    #[test]
    fn cp_sat_runtime_can_solve_minimal_model() {
        // 这条测试只验证 Rust binding + OR-Tools runtime 已经真实可调用，
        // 不代表医院排班模型已经完成映射。
        let mut model = CpModelBuilder::default();
        let x = model.new_int_var_with_name([(0, 2)], "x");
        let y = model.new_int_var_with_name([(0, 2)], "y");

        model.add_ne(x, y);

        let response = model.solve();

        assert_eq!(response.status(), CpSolverStatus::Optimal);
        assert_ne!(x.solution_value(&response), y.solution_value(&response));
    }
}
