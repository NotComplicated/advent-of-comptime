const std = @import("std");
const utils = @import("../utils.zig");

pub const sample =
    \\123 328  51 64
    \\ 45 64  387 23
    \\  6 98  215 314
    \\*   +   *   +
    \\
;

pub fn part1(input: []const u8) !i64 {
    const last_line = input[std.mem.lastIndexOfScalar(u8, input[0 .. input.len - 1], '\n').?..];
    var ops_iter = std.mem.tokenizeScalar(u8, last_line, ' ');
    var ops: []const enum { add, mult } = &.{};
    while (ops_iter.next()) |op| ops = ops ++ .{if (op[0] == '+') .add else .mult};
    var buckets: [ops.len]u64 = undefined;
    for (&buckets, ops) |*bucket, op| bucket.* = if (op == .add) 0 else 1;
    var lines = utils.iterLines(input[0 .. input.len - last_line.len]);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var num_iter = std.mem.tokenizeScalar(u8, line, ' ');
        for (&buckets, ops) |*bucket, op| {
            const num = try std.fmt.parseUnsigned(u64, num_iter.next().?, 10);
            if (op == .add) bucket.* += num else bucket.* *= num;
        }
    }
    var sum = 0;
    for (buckets) |bucket| sum += bucket;
    return sum;
}

pub fn part2(input: []const u8) !i64 {
    const num_lines = std.mem.count(u8, input, "\n");
    var lines: [num_lines][]const u8 = undefined;
    var lines_iter = utils.iterLines(input);
    for (&lines) |*line| {
        line.* = lines_iter.next().?;
    }
    const longest = l: {
        var l = 0;
        for (lines) |line| l = @max(l, line.len);
        break :l l;
    };
    for (&lines) |*line| if (line.len < longest) {
        var new_line: [longest]u8 = .{' '} ** longest;
        @memmove(new_line[0..line.len], line.*);
        line.* = &new_line;
    };
    var sum = 0;
    var current: u64 = undefined;
    var op: enum { add, mult } = undefined;
    for (0..longest) |i| {
        if (lines[num_lines - 1][i] != ' ') {
            current = if (lines[num_lines - 1][i] == '+') 0 else 1;
            op = if (lines[num_lines - 1][i] == '+') .add else .mult;
        }
        var num = 0;
        var all_spaces = true;
        for (0..num_lines - 1) |j| {
            if (lines[j][i] == ' ') continue;
            all_spaces = false;
            num *= 10;
            num += lines[j][i] - '0';
        }
        if (all_spaces)
            sum += current
        else
            current = if (op == .add) current + num else current * num;
    }
    sum += current;
    return sum;
}
