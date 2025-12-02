const std = @import("std");

pub fn iterLines(input: []const u8) std.mem.SplitIterator(u8, .scalar) {
    return std.mem.splitScalar(u8, input, '\n');
}
