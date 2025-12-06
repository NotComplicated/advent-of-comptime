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
        const row = i / cols;
        const col = i % cols;
        var count = 0;
        if (row > 0) {
            const x = (row - 1) * cols;
            if (col > 0 and input[x + col - 1] == '@') count += 1;
            if (input[x + col] == '@') count += 1;
            if (col < cols - 1 and input[x + col + 1] == '@') count += 1;
        }
        if (col > 0 and input[row * cols + col - 1] == '@') count += 1;
        if (col < cols - 1 and input[row * cols + col + 1] == '@') count += 1;
        if (row < input.len / cols - 1) {
            const x = (row + 1) * cols;
            if (col > 0 and input[x + col - 1] == '@') count += 1;
            if (input[x + col] == '@') count += 1;
            if (col < cols - 1 and input[x + col + 1] == '@') count += 1;
        }
        if (count < 4) sum += 1;
    }
    return sum;
}

pub fn part2(input: []const u8) !i64 {
    const cols = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var rolls: [input.len]u8 = input[0..].*;
    var sum = 0;
    while (true) {
        const removed = remove(rolls[0..], cols);
        if (removed == 0) return sum;
        sum += removed;
    }
}

fn remove(rolls: []u8, cols: usize) i64 {
    var removed = 0;
    for (0..rolls.len) |i| {
        if (rolls[i] != '@') continue;
        const row = i / cols;
        const col = i % cols;
        var count = 0;
        if (row > 0) {
            const x = (row - 1) * cols;
            if (col > 0 and rolls[x + col - 1] == '@') count += 1;
            if (rolls[x + col] == '@') count += 1;
            if (col < cols - 1 and rolls[x + col + 1] == '@') count += 1;
        }
        if (col > 0 and rolls[i - 1] == '@') count += 1;
        if (col < cols - 1 and rolls[i + 1] == '@') count += 1;
        if (row < rolls.len / cols - 1) {
            const x = (row + 1) * cols;
            if (col > 0 and rolls[x + col - 1] == '@') count += 1;
            if (rolls[x + col] == '@') count += 1;
            if (col < cols - 1 and rolls[x + col + 1] == '@') count += 1;
        }
        if (count < 4) {
            rolls[i] = '.';
            removed += 1;
        }
    }
    return removed;
}
