const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "boxer",
        .target = target,
        .root_source_file = b.path("src/boxer.zig"),
        .optimize = optimize,
    });
    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("src"));
    switch (target.result.os.tag) {
        .windows => {
            lib.defineCMacro("UNICODE", "1");
            lib.addCSourceFile(.{ .file = b.path("src/boxer_win.c"), .flags = &.{} });
        },
        .linux => {},
        .macos => {
            lib.defineCMacro("__kernel_ptr_semantics", "");

            @import("xcode_frameworks").addPaths(&lib.root_module);

            lib.addCSourceFile(.{ .file = b.path("src/boxer_mac.m"), .flags = &.{} });

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
        .root_source_file = b.path("examples/example.zig"),
        .optimize = optimize,
    });
    if (target.result.isDarwin()) {
        try exe.root_module.include_dirs.appendSlice(b.allocator, lib.root_module.include_dirs.items);
        try exe.root_module.lib_paths.appendSlice(b.allocator, lib.root_module.lib_paths.items);
    }
    exe.linkLibC();
    exe.addIncludePath(b.path("include"));
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
