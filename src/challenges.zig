const std = @import("std");

const days = .{
    @import("days/day01.zig"),
    @import("days/day02.zig"),
    @import("days/day03.zig"),
    @import("days/day04.zig"),
    @import("days/day05.zig"),
    @import("days/day06.zig"),
    @import("days/day07.zig"),
    @import("days/day08.zig"),
    @import("days/day09.zig"),
    @import("days/day10.zig"),
    @import("days/day11.zig"),
    @import("days/day12.zig"),
};

pub const results = results: {
    var rs: [days.len][]const u8 = undefined;
    for (days, &rs) |day, *r| {
        r.* = day.result;
    }
    break :results rs;
};
