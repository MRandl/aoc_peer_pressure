const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, file_name: []const u8, buf_handler: *const fn ([]u8) u32) !u32 {
    var sum: u32 = 0;
    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());

    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    while (true) {
        reader.reader().streamUntilDelimiter(buffer.writer(), '\n', null) catch |e| switch (e) {
            error.EndOfStream => break,
            else => return e,
        };

        sum += buf_handler(buffer.items);
        buffer.clearRetainingCapacity();
    }

    return sum;
}
