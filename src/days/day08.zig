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
            unit_size = @min(unit_size, @ceil(std.math.sqrt(dx * dx + dy * dy + dz * dz)));
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
    {
        var lines = utils.iterLines(input);
        while (lines.next()) |line| {
            if (line.len == 0) break;
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
    }
    var conns: []const Connection = &.{};
    const max_conns = switch (part) {
        .one => if (input.ptr == sample.ptr) 10 else 1000,
        .two => if (input.ptr == sample.ptr) 50 else 5000,
    };
    for (1..units + 1) |x| for (1..units + 1) |y| for (1..units + 1) |z| {
        for (buckets[x][y][z]) |junction| {
            for (x - 1..x + 2) |x_adj| for (y - 1..y + 2) |y_adj| for (z - 1..z + 2) |z_adj| {
                for (buckets[x_adj][y_adj][z_adj]) |adj_junction| {
                    if (std.meta.eql(junction, adj_junction)) continue;
                    const dx = junction[0] - adj_junction[0];
                    const dy = junction[1] - adj_junction[1];
                    const dz = junction[2] - adj_junction[2];
                    const dist = std.math.sqrt(dx * dx + dy * dy + dz * dz);
                    const at = std.sort.lowerBound(
                        Connection,
                        conns,
                        dist,
                        struct {
                            fn f(d: f32, conn: Connection) std.math.Order {
                                return std.math.order(d, conn.dist);
                            }
                        }.f,
                    );
                    if (at <= max_conns) {
                        const new_conn: Connection = .{
                            .dist = dist,
                            .first = junction,
                            .second = adj_junction,
                        };
                        if (at == conns.len or !std.meta.eql(conns[at].first, adj_junction))
                            conns = conns[0..at] ++ .{new_conn} ++ conns[at..];
                    }
                }
            };
        }
    };
    var conns_sorted = conns[0..].*;
    std.sort.pdq(
        Connection,
        &conns_sorted,
        {},
        struct {
            fn f(_: void, l: Connection, r: Connection) bool {
                return l.dist < r.dist;
            }
        }.f,
    );
    var circuits: [max_conns][]const Junction = .{&.{}} ** max_conns;
    var circuits_len = 1;
    for (0..max_conns) |i| {
        const conn = conns_sorted[i];
        var found: [2]?usize = .{ null, null };
        var first_empty: ?usize = null;
        for (.{ conn.first, conn.second }, &found) |junction, *at| {
            circuits: for (0..circuits_len) |j| {
                if (first_empty == null and circuits[j].len == 0) first_empty = j;
                for (circuits[j]) |prev_junction| {
                    if (std.meta.eql(junction, prev_junction)) {
                        at.* = j;
                        break :circuits;
                    }
                }
            }
        }
        @compileLog(conn.first, conn.second);
        if (found[0]) |first| {
            if (found[1]) |second| {
                if (first != second) {
                    circuits[first] = circuits[first] ++ circuits[second];
                    circuits[second] = &.{};
                    if (part == .two) {
                        var all_empty = true;
                        for (0..circuits_len) |j| {
                            if (j == first) continue;
                            if (circuits[j].len != 0) {
                                all_empty = false;
                                break;
                            }
                        }
                        if (all_empty) {
                            @compileLog(conn.first, conn.second);
                            return conn.first[0] * conn.second[0];
                        }
                    }
                }
            } else circuits[first] = circuits[first] ++ .{conn.second};
        } else if (found[1]) |second|
            circuits[second] = circuits[second] ++ .{conn.first}
        else {
            circuits[first_empty.?] = &.{ conn.first, conn.second };
            circuits_len = @max(circuits_len, first_empty.? + 2);
        }
        for (circuits) |c| {
            if (c.len != 0) @compileLog(c.len);
        }
    }
    if (part == .two) return error.NotEnoughConnections;
    std.sort.pdq(
        []const Junction,
        circuits[0..circuits_len],
        {},
        struct {
            fn f(_: void, l: []const Junction, r: []const Junction) bool {
                return l.len > r.len;
            }
        }.f,
    );
    var product = 1;
    for (circuits[0..3]) |circuit| product *= @max(circuit.len, 1);
    return product;
}
