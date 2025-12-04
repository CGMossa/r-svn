// Test Rust source file for R build system
// This file tests that .rs -> .o compilation works

#[no_mangle]
pub extern "C" fn rust_hello() -> i32 {
    42
}

#[no_mangle]
pub extern "C" fn rust_add(a: i32, b: i32) -> i32 {
    a + b
}
