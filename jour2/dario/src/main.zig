const std = @import("std");
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

pub fn main() !void {

    var br = std.io.bufferedReader(std.io.getStdIn().reader());
    const stdin = br.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var valid_game_sum: u64 = 0;

    while (true) {
        const line = 
            try 
                stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 200) 
            orelse 
                break;
        var splitter = std.mem.split(u8, line, " ");
        const gamestr = splitter.next() orelse unreachable;
        try expect(std.mem.eql(u8, gamestr, "Game"));
        const gameidxstr = splitter.next() orelse unreachable;
        const gameidx = std.fmt.parseInt(u64, gameidxstr, 10) catch unreachable;
        valid_game_sum += gameidx;
    }

    try stdout.print("Number of lines = {}\n", .{valid_game_sum});

}