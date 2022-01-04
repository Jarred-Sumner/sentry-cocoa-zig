const mode: std.builtin.Mode = @import("builtin").mode;
const is_test: bool = @import("builtin").is_test;
pub const sentry_on_crashed_last_run_callback = ?fn (?*anyopaque) callconv(.C) void;
pub const sentry_before_send_event_callback = ?fn (?*anyopaque) callconv(.C) void;
pub const struct_sentry_options_t = extern struct {
    enabled: bool = true,
    debug: bool = mode == .debug or is_test,
    enable_out_of_memory_tracking: bool = true,
    enable_swizzling: bool = false,
    dsn: [*:0]const u8 = "",
    release_name: [*:0]const u8 = "",
    on_before_send: sentry_before_send_event_callback = null,
    on_crashed_last_run: sentry_on_crashed_last_run_callback = null,
};
pub const sentry_options_t = struct_sentry_options_t;
pub extern fn sentry_startSentry(options: *const sentry_options_t) void;
pub extern fn sentry_captureMessage(msg: [*:0]const u8) void;
pub extern fn sentry_stopSentry() void;
pub extern fn sentry_didCrashLastRun() bool;
pub extern fn sentry_isEnabled() bool;
pub extern fn sentry_crash() void;

const std = @import("std");

pub const Sentry = struct {
    pub inline fn start(options: struct_sentry_options_t) void {
        var opts = options;
        sentry_startSentry(&opts);
    }

    pub inline fn captureMessage(msg: [:0]const u8) void {
        std.debug.assert(sentry_isEnabled());
        sentry_captureMessage(msg);
    }

    pub inline fn stop() void {
        sentry_stopSentry();
    }

    pub inline fn crash() void {
        sentry_crash();
    }

    pub inline fn didCrashLastRun() bool {
        return sentry_didCrashLastRun();
    }

    pub inline fn isEnabled() bool {
        return sentry_isEnabled();
    }
};

test "Sentry start" {
    Sentry.start(struct_sentry_options_t{
        .enabled = true,
        .debug = true,
        .release_name = "sentry-cocoa-zig-test-1.0",
        // .dsn = "https://3bfc34ee0b624366be3b918bfcdf25cd:24fd460f12b84e01838032ee5bf9a0ee@o244632.ingest.sentry.io/6133230",
    });
}

test "Sentry crash" {
    Sentry.start(struct_sentry_options_t{
        .enabled = true,
        .debug = false,
        .release_name = "sentry-cocoa-zig-test-1.0",
        // .dsn = "https://3bfc34ee0b624366be3b918bfcdf25cd:24fd460f12b84e01838032ee5bf9a0ee@o244632.ingest.sentry.io/6133230",
    });
    Sentry.captureMessage("Hello");
}
