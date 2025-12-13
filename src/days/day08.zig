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

const Junction = struct { x: f64, y: f64, z: f64, circuit: ?usize = null };
const Connection = struct { dist: f64, first: *Junction, second: *Junction };

pub fn part1(input: []const u8) !i64 {
    return inner(input, .one);
}

pub fn part2(input: []const u8) !i64 {
    return inner(input, .two);
}

fn inner(input: []const u8, part: enum { one, two }) !u32 {
    var junctions: [1000]Junction = undefined;
    var junctions_len = 0;
    var unit_size = std.math.maxInt(usize);
    var largest = 0;
    var lines = utils.iterLines(input);
    while (lines.next()) |line| {
        if (line.len == 0) break;
        const next_line = lines.next().?;
        var fields = utils.iterCommas(line);
        var next_fields = utils.iterCommas(next_line);
        junctions[junctions_len] = .{
            .x = try std.fmt.parseFloat(f64, fields.next().?),
            .y = try std.fmt.parseFloat(f64, fields.next().?),
            .z = try std.fmt.parseFloat(f64, fields.next().?),
        };
        junctions[junctions_len + 1] = .{
            .x = try std.fmt.parseFloat(f64, next_fields.next().?),
            .y = try std.fmt.parseFloat(f64, next_fields.next().?),
            .z = try std.fmt.parseFloat(f64, next_fields.next().?),
        };
        const dx = junctions[junctions_len].x - junctions[junctions_len + 1].x;
        const dy = junctions[junctions_len].y - junctions[junctions_len + 1].y;
        const dz = junctions[junctions_len].z - junctions[junctions_len + 1].z;
        unit_size = @min(unit_size, @ceil(@sqrt(dx * dx + dy * dy + dz * dz)));
        largest = @max(
            largest,
            junctions[junctions_len].x,
            junctions[junctions_len].y,
            junctions[junctions_len].z,
            junctions[junctions_len + 1].x,
            junctions[junctions_len + 1].y,
            junctions[junctions_len + 1].z,
        );
        junctions_len += 2;
    }
    unit_size = @ceil(unit_size * 1.2);
    const units = largest / unit_size + 1;
    var buckets: [units + 2][units + 2][units + 2][]const *Junction = undefined;
    for (&buckets) |*x| for (x) |*xy| for (xy) |*xyz| {
        xyz.* = &.{};
    };
    for (junctions[0..junctions_len]) |*junction| {
        const x = @divFloor(junction.x, unit_size) + 1;
        const y = @divFloor(junction.y, unit_size) + 1;
        const z = @divFloor(junction.z, unit_size) + 1;
        buckets[x][y][z] = buckets[x][y][z] ++ .{junction};
    }
    const max_conns, const max_circuits = switch (part) {
        .one => if (input.ptr == sample.ptr) .{ 10, 5 } else .{ 1000, 300 },
        .two => if (input.ptr == sample.ptr) .{ 40, 10 } else .{ 4800, 800 },
    };
    var conns: [max_conns]Connection = undefined;
    var conns_len = 0;
    for (1..units + 1) |x0| for (1..units + 1) |y0| for (1..units + 1) |z0| {
        for (buckets[x0][y0][z0]) |first| {
            for (x0 - 1..x0 + 2) |x1| for (y0 - 1..y0 + 2) |y1| for (z0 - 1..z0 + 2) |z1| {
                for (buckets[x1][y1][z1]) |second| {
                    if (first.x == second.x and first.y == second.y and first.z == second.z) continue;
                    const dx = first.x - second.x;
                    const dy = first.y - second.y;
                    const dz = first.z - second.z;
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
                        if (prev_first.x != second.x or prev_first.y != second.y or prev_first.z != second.z) {
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
    var circuits: [max_circuits][conns_len]*Junction = undefined;
    var circuit_lens: [max_circuits]usize = undefined;
    var circuits_len = 0;
    for (conns[0..conns_len]) |conn| {
        var new_len = 0;
        if (conn.first.circuit) |first_circuit| {
            if (conn.second.circuit) |second_circuit| {
                if (first_circuit != second_circuit) {
                    for (circuits[second_circuit][0..circuit_lens[second_circuit]]) |junction|
                        junction.circuit = first_circuit;
                    @memcpy(
                        circuits[first_circuit][circuit_lens[first_circuit]..].ptr,
                        circuits[second_circuit][0..circuit_lens[second_circuit]],
                    );
                    circuit_lens[first_circuit] += circuit_lens[second_circuit];
                    circuit_lens[second_circuit] = 0;
                    conn.second.circuit = first_circuit;
                    new_len = circuit_lens[first_circuit];
                }
            } else {
                circuits[first_circuit][circuit_lens[first_circuit]] = conn.second;
                circuit_lens[first_circuit] += 1;
                conn.second.circuit = first_circuit;
                new_len = circuit_lens[first_circuit];
            }
        } else if (conn.second.circuit) |second_circuit| {
            circuits[second_circuit][circuit_lens[second_circuit]] = conn.first;
            circuit_lens[second_circuit] += 1;
            conn.first.circuit = second_circuit;
            new_len = circuit_lens[second_circuit];
        } else {
            circuits[circuits_len][0] = conn.first;
            circuits[circuits_len][1] = conn.second;
            circuit_lens[circuits_len] = 2;
            conn.first.circuit = circuits_len;
            conn.second.circuit = circuits_len;
            circuits_len += 1;
        }
        if (part == .two and new_len == junctions_len) return conn.first.x * conn.second.x;
    }
    if (part == .two) return error.NotEnoughConnections;
    var maxes: [3]usize = .{1} ** 3;
    for (circuit_lens[0..circuits_len]) |circuit_len| {
        if (circuit_len > maxes[0]) {
            maxes[2] = maxes[1];
            maxes[1] = maxes[0];
            maxes[0] = circuit_len;
        } else if (circuit_len > maxes[1]) {
            maxes[2] = maxes[1];
            maxes[1] = circuit_len;
        } else if (circuit_len > maxes[2]) maxes[2] = circuit_len;
    }
    return maxes[0] * maxes[1] * maxes[2];
}
