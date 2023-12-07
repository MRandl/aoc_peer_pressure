const std = @import("std");
const helper = @import("./helper.zig");

const WORDS = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn maybe_digit(slice: []u8) i32 {
    for (WORDS, 0..) |w, i| {
        if (std.mem.startsWith(u8, slice, w)) {
            return @intCast(i);
        }
    }

    return -1;
}

fn handler(buffer: []u8) u32 {
    var first: ?u32 = null;
    var last: ?u32 = null;

    for (buffer, 0..) |c, i| {
        var digit: ?u32 = null;

        if (std.ascii.isDigit(c)) {
            digit = c - '0';
        } else {
            const idx = maybe_digit(buffer[i..]);
            if (idx > -1) {
                digit = @intCast(idx);
            }
        }

        if (digit != null) {
            if (first == null) {
                first = digit.?;
            }
            last = digit.?;
        }
    }

    return first.? * 10 + last.?;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var args = std.process.args();
    _ = args.skip();

    const writer = std.io.getStdOut().writer();

    while (args.next()) |f| {
        const res = try helper.solve(allocator, f, handler);
        try writer.print("{s}: {}\n", .{ f, res });
    }
}
