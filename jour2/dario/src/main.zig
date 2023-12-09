const std = @import("std");
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

const allowed_red = 12;
const allowed_green = 13;
const allowed_blue = 14;

pub fn main() !void {

    var br = std.io.bufferedReader(std.io.getStdIn().reader());
    const stdin = br.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var valid_game_sum: u64 = 0;

    // Iterate on all lines
    lineloop: while (true) {

        // Get The lines by splitting on \n
        const line = 
            try 
                stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 200) 
            orelse 
                break;
            
        var splitter = std.mem.split(u8, line, " ");

        // Expect that lines are not empty (and that they start with "Game")
        const gamestr = splitter.next() orelse unreachable;
        try expect(std.mem.eql(u8, gamestr, "Game"));

        // The game index is the next word. Need to drop the ':'
        const gameidxstr = splitter.next() orelse unreachable;
        const gameidx = std.fmt.parseInt(u64, gameidxstr[0..gameidxstr.len-1], 10) catch unreachable;

        // iterate on all handfuls
        while (splitter.peek() != null) {
            // declare the variable to store the amount of each balls
            var num_red : ?u32 = null;
            var num_green : ?u32 = null;
            var num_blue : ?u32 = null;

            // we'll iterate on all the other words in the handful
            colourloop: while (splitter.peek() != null) {
                const numstr = splitter.next() orelse unreachable;
                // now we expect each word to come in pairs. the first is a number that can be parsed as is
                const num = std.fmt.parseInt(u32, numstr, 10) catch unreachable;
                // the second is a string indicating the colour.
                const colourstr = splitter.next() orelse unreachable;
                // Yolo we can just look at the first char
                switch (colourstr[0]) {
                    'r' => {
                        if (num_red) |_| {
                            std.debug.print("Game {}: dupplicate red.\n", .{gameidx});
                            unreachable;
                        }
                        num_red = num;
                    },
                    'g' => {
                        if (num_green) |_| {
                            std.debug.print("Game {}: dupplicate blue.\n", .{gameidx});
                            unreachable;
                        }
                        num_green = num;
                    },
                    'b' => {
                        if (num_blue) |_| {
                            std.debug.print("Game {}: dupplicate green.\n", .{gameidx});
                            unreachable;
                        }
                        num_blue = num;
                    },
                    else => {
                        std.debug.print("Game {}: found an unknown colour: {s}.\n", .{gameidx,colourstr});
                        unreachable;
                    }
                }

                // It's the end of a handful if the colourstr ends in ';'
                if (colourstr[colourstr.len - 1] == ';') {
                    break :colourloop;
                }
            }

            // break if we have more of a colour than allowed
            if (num_red orelse 0 > allowed_red) {
                continue :lineloop;
            }
            if (num_green orelse 0 > allowed_green) {
                continue :lineloop;
            }
            if (num_blue orelse 0 > allowed_blue) {
                continue :lineloop;
            }
        }

        valid_game_sum += gameidx;
        
    }

    try stdout.print("Sum of valid games = {}\n", .{valid_game_sum});

}