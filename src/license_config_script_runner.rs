use rhai::{Dynamic, Engine, EvalAltResult, ImmutableString, Map, Scope};

// Define the Metadata and ConfigResult types
fn create_metadata() -> Map {
    let mut metadata = Map::new();

    metadata.insert("lid".into(), Dynamic::from(88_i64));
    metadata.insert("cid".into(), Dynamic::from(789_i64));
    metadata.insert("isLoggedIn".into(), Dynamic::from(true));

    let mut location = Map::new();
    location.insert("zone".into(), Dynamic::from("Europe"));
    location.insert("country".into(), Dynamic::from("DE"));
    location.insert("isEu".into(), Dynamic::from(true));
    location.insert("ip".into(), Dynamic::from("192.168.1.1"));
    metadata.insert("location".into(), location.into());

    let mut control_license = Map::new();
    control_license.insert("active".into(), Dynamic::from(false));
    control_license.insert("maxRosterItemCount".into(), Dynamic::from(10));
    control_license.insert("maxRosterCount".into(), Dynamic::from(100));
    metadata.insert("controlLicense".into(), control_license.into());

    metadata.insert("custom.client.id".into(), Dynamic::from("client_123"));
    metadata.insert("system.language".into(), Dynamic::from("en"));
    metadata.insert("client.language".into(), Dynamic::from("en"));
    metadata.insert(
        "current_license_name".into(),
        Dynamic::from("professional-1"),
    );
    metadata.insert("system.os_type".into(), Dynamic::from("windows"));

    metadata
}

fn create_state() -> Map {
    let state = Map::new(); // Empty state for this example
    state
}

// rhai script calls this apply config callback
fn apply_config_fn(result: &mut Map, config_name: ImmutableString) {
    match result.get_mut("sharedKeys") {
        Some(shared_keys_dynamic) => {
            if let Some(mut shared_keys) = shared_keys_dynamic.write_lock::<Map>() {
                shared_keys.insert(config_name.clone().into(), Dynamic::from("Applied"));
            }
        }
        None => panic!("sharedKeys is not found in the result map."),
    }
}

pub fn run_license_config() -> Result<(), Box<EvalAltResult>> {
    let mut engine = Engine::new();

    let script = match engine.compile_file("src/license_config_script.rhai".into()) {
        Ok(script) => script,
        Err(e) => return Err(e),
    };

    engine.register_fn("applyConfigFn", apply_config_fn);

    let metadata = create_metadata();
    let state = create_state();

    let mut config_result = Map::new();
    config_result.insert("sharedKeys".into(), Dynamic::from(Map::new()));
    config_result.insert("privateKeys".into(), Dynamic::from(Map::new()));

    let mut scope = Scope::new();
    scope.push("result", config_result);

    let config_result: Dynamic = engine.call_fn(&mut scope, &script, "infer", (metadata, state))?;

    let config_map = config_result.cast::<Map>();

    println!("Final Config Result: {:?}", config_map);

    Ok(())
}
