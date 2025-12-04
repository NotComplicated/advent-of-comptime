const std = @import("std");
const utils = @import("../utils.zig");

pub const sample =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

pub fn part1(input: []const u8) !i64 {
    var sum = 0;
    var lines = utils.iterLines(input);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        sum += recurse(line, 2);
    }
    return sum;
}

pub fn part2(input: []const u8) !i64 {
    var sum = 0;
    var lines = utils.iterLines(input);
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        sum += recurse(line, 12);
    }
    return sum;
}

fn recurse(bank: []const u8, batteries: usize) usize {
    if (batteries == 0) return 0;
    var this_battery = 0;
    var this_battery_pos = 0;
    for (bank[0 .. bank.len - (batteries - 1)], 0..) |c, i| {
        const battery = c - '0';
        if (battery > this_battery) {
            this_battery = battery;
            this_battery_pos = i;
        }
    }
    const next_batteries = recurse(bank[this_battery_pos + 1 ..], batteries - 1);
    return this_battery * std.math.pow(usize, 10, batteries - 1) + next_batteries;
}
