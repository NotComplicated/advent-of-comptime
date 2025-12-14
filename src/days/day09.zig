const std = @import("std");
const utils = @import("../utils.zig");

pub const sample =
    \\7,1
    \\11,1
    \\11,7
    \\9,7
    \\9,5
    \\2,5
    \\2,3
    \\7,3
    \\
;

const Point = struct {
    x: u64,
    y: u64,
};

const max_points = 500;

fn sort(_: void, l: Point, r: Point) bool {
    return l.x < r.x;
}

pub fn part1(input: []const u8) !i64 {
    const points = try getPoints(input);
    var rights: [max_points]?Point = undefined;
    for (0..points.len) |i| {
        const point = points[i];
        rights[i] = point;
        fixAncestors(&rights, i, point);
    }
    var lefts: [max_points]?Point = undefined;
    for (0..points.len) |i| {
        const point = points[points.len - i - 1];
        lefts[i] = point;
        fixAncestors(&lefts, i, point);
    }
    var max = 0;
    for (rights[0..points.len]) |right| if (right) |r| for (lefts[0..points.len]) |left| if (left) |l| {
        const dx = @abs(@as(i64, @intCast(r.x)) - @as(i64, @intCast(l.x))) + 1;
        const dy = @abs(@as(i64, @intCast(r.y)) - @as(i64, @intCast(l.y))) + 1;
        max = @max(max, dx * dy);
    };
    return max;
}

pub fn part2(input: []const u8) !i64 {
    _ = input;
    return error.NotImplemented;
}

fn getPoints(input: []const u8) ![]const Point {
    var points: [max_points]Point = undefined;
    var points_len = 0;
    var lines = utils.iterLines(input);
    while (lines.next()) |line| {
        if (line.len == 0) break;
        const comma = std.mem.indexOfScalar(u8, line, ',').?;
        points[points_len] = .{
            .x = try std.fmt.parseUnsigned(u64, line[0..comma], 10),
            .y = try std.fmt.parseUnsigned(u64, line[comma + 1 ..], 10),
        };
        points_len += 1;
    }
    std.sort.pdq(Point, points[0..points_len], {}, sort);
    return points[0..points_len];
}

fn fixAncestors(ancestors: []?Point, i: usize, point: Point) void {
    if (i != 0) {
        const prev = ancestors[i - 1].?;
        for (0..i - 1) |j| if (ancestors[i - 1 - j - 1]) |ancestor| {
            if (point.y > prev.y) {
                if (ancestor.y >= prev.y and ancestor.y <= point.y) ancestors[i - 1 - j - 1] = null;
            } else {
                if (ancestor.y >= point.y and ancestor.y <= prev.y) ancestors[i - 1 - j - 1] = null;
            }
        };
    }
}
