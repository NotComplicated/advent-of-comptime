const std = @import("std");
const utils = @import("../utils.zig");

pub const sample =
    \\L68
    \\L30
    \\R48
    \\L5
    \\R60
    \\L55
    \\L1
    \\L99
    \\R14
    \\L82
;

pub fn part1(input: []const u8) !i64 {
    @setEvalBranchQuota(1_000_000);
    var dial = 50;
    var zeroes = 0;
    var lines = utils.iterLines(input);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const amount = try std.fmt.parseInt(i64, line[1..], 10);
        if (line[0] == 'L') dial -= amount else dial += amount;
        dial = @mod(dial, 100);
        if (dial == 0) zeroes += 1;
    }
    return zeroes;
}

pub fn part2(input: []const u8) !i64 {
    var dial = 50;
    var zeroes = 0;
    var lines = utils.iterLines(input);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const amount = try std.fmt.parseInt(i64, line[1..], 10);
        const new_dial = if (line[0] == 'L') dial - amount else dial + amount;
        const dist = if (new_dial <= 0)
            -new_dial + (if (dial == 0) 0 else 100)
        else
            new_dial;
        zeroes += @intFromFloat(@as(f32, @floatFromInt(dist)) / 100.0);
        dial = @mod(new_dial, 100);
    }
    return zeroes;
}
