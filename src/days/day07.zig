const std = @import("std");
const utils = @import("../utils.zig");

pub const sample =
    \\.......S.......
    \\...............
    \\.......^.......
    \\...............
    \\......^.^......
    \\...............
    \\.....^.^.^.....
    \\...............
    \\....^.^...^....
    \\...............
    \\...^.^...^.^...
    \\...............
    \\..^...^.....^..
    \\...............
    \\.^.^.^.^.^...^.
    \\...............
    \\
;

pub fn part1(input: []const u8) !i64 {
    var lines = utils.iterLines(input);
    const first_line = lines.next().?;
    _ = lines.next();
    var tiles: [first_line.len]enum { on, off } = undefined;
    for (&tiles, 0..) |*tile, i| tile.* = if (first_line[i] == 'S') .on else .off;
    var count = 0;
    while (lines.next()) |line| : (_ = lines.next()) {
        if (line.len == 0) break;
        for (line, 0..) |c, i| if (c == '^' and tiles[i] == .on) {
            tiles[i - 1 ..][0..3].* = .{ .on, .off, .on };
            count += 1;
        };
    }
    return count;
}

pub fn part2(input: []const u8) !i64 {
    var lines = utils.iterLines(input);
    const first_line = lines.next().?;
    _ = lines.next();
    var timelines: [first_line.len]u64 = undefined;
    for (&timelines, 0..) |*tls, i| tls.* = if (first_line[i] == 'S') 1 else 0;
    while (lines.next()) |line| : (_ = lines.next()) {
        if (line.len == 0) break;
        for (line, 0..) |c, i| if (c == '^' and timelines[i] > 0) {
            timelines[i - 1] += timelines[i];
            timelines[i + 1] += timelines[i];
            timelines[i] = 0;
        };
    }
    var count = 0;
    for (timelines) |tls| count += tls;
    return count;
}
