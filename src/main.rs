use license_config_script_runner::run_license_config;

pub mod license_config_script_runner;

fn main() {
    match run_license_config() {
        Ok(_) => println!("Successfully ran the script!"),
        Err(e) => println!("Could not run the script: {:?}", e),
    }
}
