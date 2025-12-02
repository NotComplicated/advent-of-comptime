const std = @import("std");
const challenges = @import("advent_of_comptime");

pub fn main() !void {
    for (1.., challenges.results) |i, result| {
        std.debug.print("Challenge {d:02}: {s}\n", .{ i, result });
    }
}
