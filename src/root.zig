const std = @import("std");
const samples_only = @import("options").samples_only;

const days = .{
    @import("days/day01.zig"),
    @import("days/day02.zig"),
    @import("days/day03.zig"),
    @import("days/day04.zig"),
    @import("days/day05.zig"),
    @import("days/day06.zig"),
    @import("days/day07.zig"),
    @import("days/day08.zig"),
    @import("days/day09.zig"),
    @import("days/day10.zig"),
    @import("days/day11.zig"),
    @import("days/day12.zig"),
};

pub const Results = struct {
    part1_sample: anyerror!i64,
    part1_input: anyerror!i64,
    part2_sample: anyerror!i64,
    part2_input: anyerror!i64,
};

pub const results = results: {
    @setEvalBranchQuota(1_000_000_000);
    var rs: [days.len]Results = undefined;
    for (days, &rs, 1..) |day, *r, i| {
        const input_path = std.fmt.comptimePrint("inputs/day{d:02}.txt", .{i});
        const input = @embedFile(input_path);
        r.part1_sample = day.part1(day.sample);
        r.part1_input = if (samples_only) error.SamplesOnly else day.part1(input);
        r.part2_sample = day.part2(day.sample);
        r.part2_input = if (samples_only) error.SamplesOnly else day.part2(input);
    }
    break :results rs;
};
