const std = @import("std");
const challenges = @import("advent_of_comptime");

pub fn main() !void {
    comptime var out: []const u8 = "";
    inline for (1.., challenges.results) |i, results| {
        out = out ++ std.fmt.comptimePrint(
            \\Challenge {d:02}:
            \\  Part 1 (sample): {!}
            \\  Part 1 (input): {!}
            \\  Part 2 (sample): {!}
            \\  Part 2 (input): {!}
            \\
            \\
        ,
            .{
                i,
                results.part1_sample,
                results.part1_input,
                results.part2_sample,
                results.part2_input,
            },
        );
    }
    var writer = std.fs.File.stdout().writer(&.{});
    try writer.interface.writeAll(out);
}
