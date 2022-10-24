use env_logger::Builder;
use env_logger::Env;
use std::sync::Once;

static INIT: Once = Once::new();

/// Setup function that is only run once, even if called multiple times.
pub fn setup(name: &str, test: bool) {
    INIT.call_once(|| {
        let e = Env::default()
            .filter_or("RUST_LOG", "info")
            .write_style_or("RUST_LOG_STYLE", "always");
        let mut builder2 = Builder::from_env(e);
        builder2.is_test(test);
        let _ = builder2.try_init();
    });
    debug!("{} initialized!", name);
}
