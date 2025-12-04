const std = @import("std");

pub fn Set(T: type) type {
    return struct {
        items: []const T = &.{},

        pub const Iter = struct {
            set: *const Set(T),
            index: usize = 0,

            pub fn next(self: *@This()) ?T {
                if (self.index >= self.set.items.len) return null;
                const item = self.set.items[self.index];
                self.index += 1;
                return item;
            }
        };

        pub fn iter(self: *const @This()) Iter {
            return .{ .set = self };
        }

        pub fn insert(self: *@This(), item: T) void {
            if (!self.contains(item)) self.items = self.items ++ .{item};
        }

        pub fn contains(self: @This(), item: T) bool {
            for (self.items) |i| if (i == item) return true;
            return false;
        }
    };
}

pub fn iterLines(input: []const u8) std.mem.SplitIterator(u8, .scalar) {
    return std.mem.splitScalar(u8, input, '\n');
}

pub fn iterCommas(input: []const u8) std.mem.SplitIterator(u8, .scalar) {
    return std.mem.splitScalar(u8, input, ',');
}
