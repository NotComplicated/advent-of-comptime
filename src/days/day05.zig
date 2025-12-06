const std = @import("std");
const utils = @import("../utils.zig");

pub const sample =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
    \\
;

const Bound = struct { u64, enum { left, right, single } };

pub fn part1(input: []const u8) !i64 {
    var lines = utils.iterLines(input);
    var bounds: [std.mem.count(u8, input, "-") * 2]Bound = undefined;

    var i = 0;
    while (lines.next()) |line| : (i += 2) {
        if (line.len == 0) break;
        var iter = std.mem.splitScalar(u8, line, '-');
        bounds[i] = .{ try std.fmt.parseInt(u64, iter.next().?, 10), .left };
        bounds[i + 1] = .{ try std.fmt.parseInt(u64, iter.next().?, 10), .right };
    }

    std.sort.pdq(
        Bound,
        &bounds,
        {},
        struct {
            fn f(_: void, l: Bound, r: Bound) bool {
                return if (l[0] == r[0]) l[1] == .left else l[0] < r[0];
            }
        }.f,
    );

    var at = 0;
    var depth = 0;
    for (bounds) |bound| {
        if (bound[1] == .left) {
            if (depth == 0) {
                if (at != 0 and bounds[at - 1][0] == bound[0]) {
                    if (bounds[at - 1][1] == .single)
                        bounds[at - 1][1] = .left
                    else
                        at -= 1;
                } else {
                    bounds[at] = bound;
                    at += 1;
                }
            }
            depth += 1;
        } else {
            depth -= 1;
            if (depth == 0) {
                if (bounds[at - 1][0] == bound[0]) {
                    bounds[at - 1][1] = .single;
                } else {
                    bounds[at] = bound;
                    at += 1;
                }
            }
        }
    }
    if (depth != 0) @panic("bounds invalid");
    const new_bounds = bounds[0..at];

    var count = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const num = try std.fmt.parseInt(u64, line, 10);
        const pos = std.sort.lowerBound(
            Bound,
            new_bounds,
            num,
            struct {
                fn f(n: u64, bound: Bound) std.math.Order {
                    return std.math.order(n, bound[0]);
                }
            }.f,
        );
        if (pos < new_bounds.len and (num == new_bounds[pos][0] or new_bounds[pos][1] == .right))
            count += 1;
    }
    return count;
}

pub fn part2(input: []const u8) !i64 {
    var lines = utils.iterLines(input);
    var bounds: [std.mem.count(u8, input, "-") * 2]Bound = undefined;

    var i = 0;
    while (lines.next()) |line| : (i += 2) {
        if (line.len == 0) break;
        var iter = std.mem.splitScalar(u8, line, '-');
        bounds[i] = .{ try std.fmt.parseInt(u64, iter.next().?, 10), .left };
        bounds[i + 1] = .{ try std.fmt.parseInt(u64, iter.next().?, 10), .right };
    }

    std.sort.pdq(
        Bound,
        &bounds,
        {},
        struct {
            fn f(_: void, l: Bound, r: Bound) bool {
                return if (l[0] == r[0]) l[1] == .left else l[0] < r[0];
            }
        }.f,
    );

    var count = 0;
    var prev: u64 = undefined;
    var depth = 0;
    for (bounds) |bound| {
        if (bound[1] == .left) {
            if (depth == 0) prev = bound[0];
            depth += 1;
        } else {
            depth -= 1;
            if (depth == 0) count += bound[0] - prev + 1;
        }
    }
    if (depth != 0) @panic("bounds invalid");
    return count;
}
