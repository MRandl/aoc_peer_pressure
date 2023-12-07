const std = @import("std");
const helper = @import("./helper.zig");

fn handler(buffer: []u8) u32 {
    var first: ?u32 = null;
    var last: ?u32 = null;

    for (buffer) |c| {
        if (std.ascii.isDigit(c)) {
            if (first == null) {
                first = c - '0';
            }
            last = c - '0';
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
