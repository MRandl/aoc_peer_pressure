const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    inline for ([_][]const u8{ "01", "02" }) |cfg| {
        const exe = b.addExecutable(.{
            .name = "david" ++ cfg,
            .root_source_file = .{ .path = "src/main" ++ cfg ++ ".zig" },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);
    }
}
