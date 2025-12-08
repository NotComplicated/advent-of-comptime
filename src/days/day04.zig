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
    const cols = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var sum = 0;
    for (0..input.len) |i| {
        if (input[i] != '@') continue;
        if (countAdj(input, i, cols) < 4) sum += 1;
    }
    return sum;
}

pub fn part2(input: []const u8) !i64 {
    const cols = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const rows = input.len / cols;
    var rolls: [rows + 2][cols + 2]u8 = undefined;
    for (0..rows + 2) |row| for (0..cols + 2) |col| {
        rolls[row][col] = 0;
    };
    for (0..input.len) |i| {
        if (input[i] != '@') continue;
        rolls[i / cols + 1][i % cols + 1] = countAdj(input, i, cols);
    }
    var sum = 0;
    while (true) {
        var removed = 0;
        for (1..rows + 1) |row| for (1..cols + 1) |col| {
            if (rolls[row][col] == 0 or rolls[row][col] >= 4) continue;
            removed += remove(cols + 2, &rolls, row, col);
        };
        if (removed == 0) break;
        sum += removed;
    }
    return sum;
}

fn countAdj(input: []const u8, i: usize, cols: usize) u8 {
    var count = 0;
    const row = i / cols;
    const col = i % cols;
    if (row > 0) {
        const x = (row - 1) * cols;
        if (col > 0 and input[x + col - 1] == '@') count += 1;
        if (input[x + col] == '@') count += 1;
        if (col < cols - 1 and input[x + col + 1] == '@') count += 1;
    }
    if (col > 0 and input[row * cols + col - 1] == '@') count += 1;
    if (col < cols - 1 and input[row * cols + col + 1] == '@') count += 1;
    if (row < (input.len / cols) - 1) {
        const x = (row + 1) * cols;
        if (col > 0 and input[x + col - 1] == '@') count += 1;
        if (input[x + col] == '@') count += 1;
        if (col < cols - 1 and input[x + col + 1] == '@') count += 1;
    }
    return count;
}

fn remove(cols: usize, rolls: [][cols]u8, row: usize, col: usize) i64 {
    var removed = 1;
    rolls[row][col] = 0;
    for (.{ row - 1, row, row + 1 }) |r| for (.{ col - 1, col, col + 1 }) |c| {
        switch (rolls[r][c]) {
            0 => {},
            1, 2, 3, 4 => removed += remove(cols, rolls, r, c),
            else => rolls[r][c] -= 1,
        }
    };
    return removed;
}
