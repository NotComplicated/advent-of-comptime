const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const options = b.addOptions();
    const samples_only = b.option(
        bool,
        "samples-only",
        "Only generate sample results.",
    ) orelse false;
    options.addOption(bool, "samples_only", samples_only);

    const mod = b.addModule("advent_of_comptime", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });
    mod.addOptions("options", options);

    const exe = b.addExecutable(.{
        .name = "advent_of_comptime",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "advent_of_comptime", .module = mod },
            },
        }),
    });
    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
