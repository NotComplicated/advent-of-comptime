const std = @import("std");
const utils = @import("../utils.zig");

pub const sample =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
    \\
;

pub fn part1(input: []const u8) !i64 {
    const columns = std.mem.indexOfScalar(u8, input, '\n').?;
    const rows = input.len / (columns + 1);
    var rolls: [rows][columns]bool = undefined;
    var input_ptr = input.ptr;
    for (&rolls) |*row| for (row) |*roll| roll: while (true) {
        const b = input_ptr[0];
        input_ptr += 1;
        roll.* = switch (b) {
            '.' => false,
            '@' => true,
            '\n' => continue :roll,
            else => return error.Unexpected,
        };
        break :roll;
    };
    var sum = 0;
    for (0..rows) |r| for (0..columns) |c| if (rolls[r][c]) {
        var count = 0;
        if (r > 0) {
            if (c > 0 and rolls[r - 1][c - 1]) count += 1;
            if (rolls[r - 1][c]) count += 1;
            if (c < columns - 1 and rolls[r - 1][c + 1]) count += 1;
        }
        if (c > 0 and rolls[r][c - 1]) count += 1;
        if (c < columns - 1 and rolls[r][c + 1]) count += 1;
        if (r < rows - 1) {
            if (c > 0 and rolls[r + 1][c - 1]) count += 1;
            if (rolls[r + 1][c]) count += 1;
            if (c < columns - 1 and rolls[r + 1][c + 1]) count += 1;
        }
        if (count < 4) sum += 1;
    };
    return sum;
}

pub fn part2(input: []const u8) !i64 {
    _ = input;
    return error.NotImplemented;
}
