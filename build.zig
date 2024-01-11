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
    lib.addIncludePath(.{ .path = root_path ++ "include" });
    lib.addIncludePath(.{ .path = root_path ++ "src" });
    switch (target.result.os.tag) {
        .windows => {
            lib.defineCMacro("UNICODE", "1");
            lib.addCSourceFile(.{ .file = .{ .path = root_path ++ "src/boxer_win.c" }, .flags = &.{} });
        },
        .linux => {},
        .macos => {
            lib.defineCMacro("__kernel_ptr_semantics", "");

            @import("xcode_frameworks").addPaths(lib);

            lib.addCSourceFile(.{ .file = .{ .path = root_path ++ "src/boxer_mac.m" }, .flags = &.{} });

            lib.linkSystemLibrary("objc");

            lib.linkFramework("CoreFoundation");
            lib.linkFramework("Foundation");
            lib.linkFramework("Cocoa");
            lib.linkFramework("AppKit");
            lib.linkFramework("ApplicationServices");
            lib.linkFramework("CoreData");
            lib.linkFramework("ColorSync");
            lib.linkFramework("CoreGraphics");
            lib.linkFramework("CoreServices");
            lib.linkFramework("CoreText");
            lib.linkFramework("ImageIO");
            lib.linkFramework("CFNetwork");
        },
        else => @panic("Unknown target!"),
    }
    lib.linkLibC();
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "example",
        .target = target,
        .root_source_file = .{ .path = root_path ++ "examples/example.zig" },
        .optimize = optimize,
    });
    if (target.result.isDarwin()) {
        @import("xcode_frameworks").addPaths(exe);
    }
    exe.linkLibC();
    exe.addIncludePath(.{ .path = root_path ++ "include" });
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

fn root() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

const root_path = root() ++ "/";
