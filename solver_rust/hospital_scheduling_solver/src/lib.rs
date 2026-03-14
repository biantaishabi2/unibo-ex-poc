pub mod explanation;
pub mod model;
pub mod output;
pub mod rules;
pub mod score;
pub mod snapshot;
pub mod solver;

pub use output::OutputSnapshot;
pub use snapshot::InputSnapshot;
pub use solver::{SolveError, solve};

