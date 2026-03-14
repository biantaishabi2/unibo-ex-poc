use std::io::{self, Read};

use hospital_scheduling_solver::{InputSnapshot, solve};

fn main() {
    let mut stdin = String::new();
    if let Err(error) = io::stdin().read_to_string(&mut stdin) {
        eprintln!("failed to read stdin: {error}");
        std::process::exit(1);
    }

    let snapshot: InputSnapshot = match serde_json::from_str(&stdin) {
        Ok(snapshot) => snapshot,
        Err(error) => {
            eprintln!("failed to decode input_snapshot: {error}");
            std::process::exit(2);
        }
    };

    let output = match solve(&snapshot) {
        Ok(output) => output,
        Err(error) => {
            eprintln!("failed to solve schedule: {error}");
            std::process::exit(3);
        }
    };

    let json = match serde_json::to_string(&output) {
        Ok(json) => json,
        Err(error) => {
            eprintln!("failed to encode output_snapshot: {error}");
            std::process::exit(4);
        }
    };

    println!("{json}");
}
