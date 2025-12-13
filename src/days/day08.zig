const std = @import("std");
const utils = @import("../utils.zig");

pub const sample =
    \\162,817,812
    \\57,618,57
    \\906,360,560
    \\592,479,940
    \\352,342,300
    \\466,668,158
    \\542,29,236
    \\431,825,988
    \\739,650,466
    \\52,470,668
    \\216,146,977
    \\819,987,18
    \\117,168,530
    \\805,96,715
    \\346,949,466
    \\970,615,88
    \\941,993,340
    \\862,61,35
    \\984,92,344
    \\425,690,689
    \\
;

const Junction = [3]f32;
const Connection = struct { dist: f32, first: Junction, second: Junction };

pub fn part1(input: []const u8) !i64 {
    return inner(input, .one);
}

pub fn part2(input: []const u8) !i64 {
    return inner(input, .two);
}

fn inner(input: []const u8, part: enum { one, two }) !u32 {
    const units, const unit_size = u: {
        var unit_size = std.math.maxInt(usize);
        var largest = 0;
        var lines = utils.iterLines(input);
        while (lines.next()) |line| {
            if (line.len == 0) break;
            const next_line = lines.next().?;
            var fields = utils.iterCommas(line);
            var next_fields = utils.iterCommas(next_line);
            var junction: Junction = undefined;
            for (&junction) |*xyz|
                xyz.* = try std.fmt.parseFloat(f32, fields.next().?);
            var next_junction: Junction = undefined;
            for (&next_junction) |*xyz|
                xyz.* = try std.fmt.parseFloat(f32, next_fields.next().?);
            const dx = junction[0] - next_junction[0];
            const dy = junction[1] - next_junction[1];
            const dz = junction[2] - next_junction[2];
            unit_size = @min(unit_size, @ceil(@sqrt(dx * dx + dy * dy + dz * dz)));
            largest = @max(
                largest,
                junction[0],
                junction[1],
                junction[2],
                next_junction[0],
                next_junction[1],
                next_junction[2],
            );
        }
        unit_size = @ceil(unit_size * 1.1);
        break :u .{ largest / unit_size + 1, unit_size };
    };
    var buckets: [units + 2][units + 2][units + 2][]const Junction = undefined;
    for (&buckets) |*x| for (x) |*xy| for (xy) |*xyz| {
        xyz.* = &.{};
    };
    const junction_count = jc: {
        var lines = utils.iterLines(input);
        var jc = 0;
        while (lines.next()) |line| {
            if (line.len == 0) break;
            jc += 1;
            var fields = utils.iterCommas(line);
            var junction: Junction = undefined;
            for (&junction) |*field| {
                field.* = try std.fmt.parseFloat(f32, fields.next().?);
            }
            const x = @divFloor(junction[0], unit_size) + 1;
            const y = @divFloor(junction[1], unit_size) + 1;
            const z = @divFloor(junction[2], unit_size) + 1;
            buckets[x][y][z] = buckets[x][y][z] ++ .{junction};
        }
        break :jc jc;
    };
    const max_conns = switch (part) {
        .one => if (input.ptr == sample.ptr) 10 else 1000,
        .two => if (input.ptr == sample.ptr) 40 else 3000,
    };
    var conns: [max_conns]Connection = undefined;
    var conns_len = 0;
    for (1..units + 1) |x0| for (1..units + 1) |y0| for (1..units + 1) |z0| {
        for (buckets[x0][y0][z0]) |first| {
            for (x0 - 1..x0 + 2) |x1| for (y0 - 1..y0 + 2) |y1| for (z0 - 1..z0 + 2) |z1| {
                for (buckets[x1][y1][z1]) |second| {
                    if (first[0] == second[0] and first[1] == second[1] and first[2] == second[2]) continue;
                    const dx = first[0] - second[0];
                    const dy = first[1] - second[1];
                    const dz = first[2] - second[2];
                    const dist = @sqrt(dx * dx + dy * dy + dz * dz);
                    const at = if (conns_len > 0 and dist < conns[conns_len - 1].dist) at: {
                        var lower = 0;
                        var upper = conns_len;
                        while (lower < upper) {
                            const mid = lower + (upper - lower) / 2;
                            if (dist > conns[mid].dist) lower = mid + 1 else upper = mid;
                        }
                        break :at lower;
                    } else conns_len;
                    if (at < conns_len) {
                        const prev_first = conns[at].first;
                        if (prev_first[0] != second[0] or prev_first[1] != second[1] or prev_first[2] != second[2]) {
                            if (conns_len < conns.len) {
                                @memmove(conns[at + 1 .. conns_len + 1], conns[at..conns_len]);
                                conns_len += 1;
                            } else @memmove(conns[at + 1 ..], conns[at .. conns.len - 1]);
                            conns[at] = .{ .dist = dist, .first = first, .second = second };
                        }
                    } else if (conns_len < conns.len) {
                        conns_len += 1;
                        conns[at] = .{ .dist = dist, .first = first, .second = second };
                    }
                }
            };
        }
    };
    var circuits: [conns_len][]const Junction = .{&.{}} ** conns_len;
    var circuits_len = 1;
    for (conns[0..conns_len]) |conn| {
        var found: [2]?usize = .{ null, null };
        var first_empty: ?usize = null;
        for (.{ conn.first, conn.second }, &found) |junction, *at| {
            circuits: for (0..circuits_len) |j| {
                if (first_empty == null and circuits[j].len == 0) first_empty = j;
                for (circuits[j]) |prev| {
                    if (junction[0] == prev[0] and junction[1] == prev[1] and junction[2] == prev[2]) {
                        at.* = j;
                        break :circuits;
                    }
                }
            }
        }
        const size = if (found[0]) |first| s: {
            if (found[1]) |second| {
                if (first != second) {
                    circuits[first] = circuits[first] ++ circuits[second];
                    circuits[second] = &.{};
                }
            } else circuits[first] = circuits[first] ++ .{conn.second};
            break :s circuits[first].len;
        } else if (found[1]) |second| s: {
            circuits[second] = circuits[second] ++ .{conn.first};
            break :s circuits[second].len;
        } else s: {
            circuits[first_empty.?] = &.{ conn.first, conn.second };
            circuits_len = @max(circuits_len, first_empty.? + 2);
            break :s 0;
        };
        if (part == .two and size == junction_count)
            return conn.first[0] * conn.second[0];
    }
    if (part == .two) return error.NotEnoughConnections;
    var maxes: [3]usize = .{1} ** 3;
    for (circuits[0..circuits_len]) |circuit| {
        if (circuit.len > maxes[0]) {
            maxes[0] = circuit.len;
            maxes[1] = maxes[0];
            maxes[2] = maxes[1];
        } else if (circuit.len > maxes[1]) {
            maxes[1] = circuit.len;
            maxes[2] = maxes[1];
        } else if (circuit.len > maxes[2]) maxes[2] = circuit.len;
    }
    return maxes[0] * maxes[1] * maxes[2];
}
