const std = @import("std");
const utils = @import("../utils.zig");

pub const sample = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

pub fn part1(input: []const u8) !i64 {
    return inner(input, .once);
}

pub fn part2(input: []const u8) !i64 {
    return inner(input, .exhaust);
}

fn inner(input: []const u8, strategy: enum { once, exhaust }) !i64 {
    var sum = 0;
    var fields = utils.iterCommas(input);
    while (fields.next()) |field| {
        const trimmed = std.mem.trimEnd(u8, field, "\n");
        var bounds = std.mem.splitScalar(u8, trimmed, '-');

        const start = try std.fmt.parseUnsigned(u64, bounds.next().?, 10);
        const start_ds = countDigits(start);
        const end = try std.fmt.parseUnsigned(u64, bounds.next().?, 10);
        const end_ds = countDigits(end);
        if (end_ds < 2) continue;

        var prev_divs: []const usize = &.{};
        div: for (2..end_ds + 1) |div| {
            {
                for (prev_divs) |prev_div| {
                    if (div % prev_div == 0) continue :div;
                }
            }

            var first_part = if (start_ds % div == 0) fp: {
                var fp = start / std.math.pow(u64, 10, start_ds - start_ds / div);
                const new_start, _ = expand(fp, div);
                if (new_start < start) fp += 1;
                break :fp fp;
            } else sfp: {
                const new_ds = start_ds + div - (start_ds % div);
                break :sfp std.math.pow(u64, 10, new_ds / div - 1);
            };

            fp: while (true) : (first_part += 1) {
                const expanded, const exp_ds = expand(first_part, div);
                if (expanded > end) break;
                for (prev_divs) |prev_div| {
                    if (exp_ds % prev_div == 0) {
                        const fpe = expanded / std.math.pow(u64, 10, exp_ds - exp_ds / prev_div);
                        const new_expanded, _ = expand(fpe, prev_div);
                        if (expanded == new_expanded) continue :fp;
                    }
                }
                sum += expanded;
            }

            var insert = true;
            for (prev_divs) |prev_div| insert &= prev_div == div;
            if (insert) prev_divs = prev_divs ++ .{div};
            if (strategy == .once) break;
        }
    }
    return sum;
}

fn countDigits(num: u64) usize {
    var n = num;
    var count = 0;
    while (n > 0) : (n /= 10) count += 1;
    return count;
}

fn expand(first_part: u64, divs: usize) struct { u64, usize } {
    const first_part_ds = countDigits(first_part);
    var expanded = 0;
    for (0..divs) |i| {
        expanded += first_part * std.math.pow(u64, 10, i * first_part_ds);
    }
    return .{ expanded, first_part_ds * divs };
}
