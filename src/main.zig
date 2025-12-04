const std = @import("std");
const challenges = @import("advent_of_comptime");

pub fn main() !void {
    comptime var out: []const u8 = "";
    inline for (1.., challenges.results) |i, results| {
        out = out ++ std.fmt.comptimePrint("Challenge {d:02}:\n", .{i});
        out = out ++ std.fmt.comptimePrint("\tPart 1 (sample): {!}\n", .{results.part1_sample});
        out = out ++ std.fmt.comptimePrint("\tPart 1 (input): {!}\n", .{results.part1_input});
        out = out ++ std.fmt.comptimePrint("\tPart 2 (sample): {!}\n", .{results.part2_sample});
        out = out ++ std.fmt.comptimePrint("\tPart 2 (input): {!}\n\n", .{results.part2_input});
    }
    const stdout = std.fs.File.stdout();
    var buf: [out.len]u8 = undefined;
    var writer = stdout.writer(&buf);
    try writer.interface.writeAll(out);
    try writer.interface.flush();
}
