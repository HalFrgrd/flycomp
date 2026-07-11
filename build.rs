use std::process::Command;

fn main() {
    // Capture git commit hash
    let git_hash = Command::new("git")
        .args(["rev-parse", "--short", "HEAD"])
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| "unknown".to_string());

    // Capture build datetime (UTC, ISO 8601) using chrono.
    // Honor SOURCE_DATE_EPOCH (https://reproducible-builds.org/specs/source-date-epoch/)
    // when set so builds are reproducible; fall back to the wall clock otherwise.
    let build_time = match std::env::var("SOURCE_DATE_EPOCH") {
        Ok(epoch) => epoch
            .parse::<i64>()
            .ok()
            .and_then(|secs| chrono::DateTime::from_timestamp(secs, 0))
            .map(|dt| dt.format("%Y-%m-%dT%H:%M:%SZ").to_string())
            .unwrap_or_else(|| "unknown".to_string()),
        Err(_) => chrono::Utc::now().format("%Y-%m-%dT%H:%M:%SZ").to_string(),
    };

    println!("cargo:rustc-env=GIT_HASH={git_hash}");
    println!("cargo:rustc-env=BUILD_TIME={build_time}");

    // Re-run when the reproducible-build timestamp changes.
    println!("cargo:rerun-if-env-changed=SOURCE_DATE_EPOCH");
    // Re-run when HEAD changes
    println!("cargo:rerun-if-changed=.git/HEAD");
    if let Ok(head) = std::fs::read_to_string(".git/HEAD")
        && let Some(refpath) = head.strip_prefix("ref: ")
    {
        println!("cargo:rerun-if-changed=.git/{}", refpath.trim());
    }
}
