const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "boxer",
        .target = target,
        .root_source_file = .{ .path = "src/boxer.zig" },
        .optimize = optimize,
    });
    lib.addIncludePath(.{ .path = "include" });
    lib.addIncludePath(.{ .path = "src" });
    switch (target.getOsTag()) {
        .windows => {
            lib.defineCMacro("UNICODE", "1");
            lib.addCSourceFile(.{ .file = .{ .path = "src/boxer_win.c" }, .flags = &.{} });
        },
        .linux => {
            // lib.linkSystemLibrary("gtk+-3.0");
        },
        .macos => {
            lib.defineCMacro("__kernel_ptr_semantics", "");

            @import("xcode_frameworks").addPaths(b, lib);

            lib.addCSourceFile(.{ .file = .{ .path = "src/boxer_mac.m" }, .flags = &.{} });

            lib.linkSystemLibraryName("objc");

            lib.linkFramework("CoreFoundation");
            lib.linkFramework("Foundation");
            lib.linkFramework("Cocoa");
            lib.linkFramework("AppKit");
        },
        else => @panic("Unknown target!"),
    }
    lib.linkLibC();
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "example",
        .target = target,
        .root_source_file = .{ .path = "examples/example.zig" },
        .optimize = optimize,
    });
    if (target.getOsTag() == .macos) {
        @import("xcode_frameworks").addPaths(b, exe);
    }
    exe.linkLibC();
    exe.addIncludePath(.{ .path = "include" });
    exe.linkLibrary(lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
