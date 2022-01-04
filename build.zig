const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("sentry-cocoa-zig", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();
    addTo(b, lib);

    const main_tests = b.addTest("src/sentry.zig");
    addTo(b, main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

pub fn addTo(b: *std.build.Builder, step: *std.build.LibExeObjStep) void {
    step.addObjectFile(b.pathFromRoot("./sentry/lib/libSentry-static.a"));
    step.addIncludeDir(b.pathFromRoot("./sentry/include"));
    step.addIncludeDir(b.pathFromRoot("src"));
    step.linkFramework("Foundation");
    step.addCSourceFile(b.pathFromRoot("./src/sentry.m"), &.{"-DSENTRY_NO"});
}
