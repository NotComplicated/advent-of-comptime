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

        for (2..end_ds + 1) |divs| {
            if (start_ds < divs) break;

            const start_first_part = if (start_ds % divs == 0) sfp: {
                var sfp = start / std.math.pow(u64, 10, start_ds - start_ds / divs);
                const new_start = expand(sfp, divs);
                if (new_start < start) sfp += 1;
                break :sfp sfp;
            } else sfp: {
                const new_ds = start_ds + divs - (start_ds % divs);
                break :sfp std.math.pow(u64, 10, new_ds / divs - 1);
            };

            const end_first_part = if (end_ds % divs == 0) efp: {
                var efp = end / std.math.pow(u64, 10, end_ds - end_ds / divs);
                const new_end = expand(efp, divs);
                if (new_end > end) efp -= 1;
                break :efp efp;
            } else efp: {
                const new_ds = end_ds - (end_ds % divs);
                break :efp std.math.pow(u64, 10, new_ds / divs) - 1;
            };

            if (start_first_part <= end_first_part) {
                for (start_first_part..end_first_part + 1) |first_part| {
                    sum += expand(first_part, divs);
                }
            }

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

fn expand(first_part: u64, divs: usize) u64 {
    const first_part_ds = countDigits(first_part);
    var expanded = 0;
    for (0..divs) |i| {
        expanded += first_part * std.math.pow(u64, 10, i * first_part_ds);
    }
    return expanded;
}
