const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var args = std.process.args();
    _ = args.skip();

    const writer = std.io.getStdOut().writer();

    while (args.next()) |f| {
        var sum: u32 = 0;

        var file = try std.fs.cwd().openFile(f, .{});
        defer file.close();

        var reader = std.io.bufferedReader(file.reader());

        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        while (true) {
            reader.reader().streamUntilDelimiter(buffer.writer(), '\n', null) catch |e| switch (e) {
                error.EndOfStream => break,
                else => return e,
            };

            var first: ?u32 = null;
            var last: ?u32 = null;

            for (buffer.items) |c| {
                if ('0' <= c and c <= '9') {
                    if (first == null) {
                        first = c - '0';
                    }
                    last = c - '0';
                }
            }

            buffer.clearRetainingCapacity();
            sum += first.? * 10 + last.?;
        }

        try writer.print("{s}: {}\n", .{ f, sum });
    }
}
