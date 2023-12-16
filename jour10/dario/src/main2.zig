const std = @import("std");
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

const CHARS_PER_LINE = 140;
const NUM_LINES = 140;

const UP : u8 = 0b0001;
const LEFT : u8 = 0b0010;
const RIGHT : u8 = 0b0100;
const DOWN : u8 = 0b1000;  

pub fn main() !void {

    var input :[NUM_LINES][CHARS_PER_LINE]u8 = undefined;

    var br = std.io.bufferedReader(std.io.getStdIn().reader());
    const stdin = br.reader();

    // Save the input in the input buffer
    for (0..NUM_LINES) |i| {
        _ = try stdin.readAll(&input[i]);
        _ = try stdin.readByte(); // for the \n
    }

    var curr_point : [2]usize = undefined;
    var curr_dir : u8 = UP; // hardcode knowing the input.

    for (input, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (char == 'S') {
                curr_point = [_]usize{i, j};
            }
        }
    }

    var area : i32 = 0;

    //unwrap the first iteration of the loop
    curr_point[0] -= 1;
    var tube = input[curr_point[0]][curr_point[1]];
    while (tube != 'S') {
        // We're in the situation:
        // Going UP from S.
        //
        // ........
        // ...F-7..
        // ..FJ.L7.
        // ..|..FJ.
        // .FS..|..
        // .L7.FJ..
        // ..L-J...
        // ........
        //
        // By trial and error, we choose
        // that going UP means sign = -1,
        // going DOWN means sign = +1
        // in order to get a positive result.
        var sign : i32 = 0;
        // Since the interior does not include the tubes
        // need to subtract 1 at some point.
        // we can subtract every time sign is +1
        // or everytime sign is -1.
        // Choosing the latter, the correction term is:
        // correction term = MIN(0, sign)
        defer area += sign * @as(i32, @intCast(curr_point[1])) + @min(0, sign);
        defer tube = input[curr_point[0]][curr_point[1]];
        switch (tube) {
            '7' => {
                if (curr_dir == RIGHT) {
                    curr_dir = DOWN;
                } else if (curr_dir == UP) {
                    curr_dir = LEFT;
                    sign = -1;
                } else unreachable;
            },
            'J','S' => {
                if (curr_dir == DOWN) {
                    curr_dir = LEFT;
                } else if (curr_dir == RIGHT) {
                    curr_dir = UP;
                    sign = -1;
                } else unreachable;
                if (tube == 'S') {
                    break;
                }
            },
            'L' => {
                if (curr_dir == DOWN) {
                    curr_dir = RIGHT;
                    sign = 1;
                } else if (curr_dir == LEFT) {
                    curr_dir = UP;
                } else unreachable;
            },
            'F' => {
                if (curr_dir == LEFT) {
                    curr_dir = DOWN;
                    sign = 1;
                } else if (curr_dir == UP) {
                    curr_dir = RIGHT;
                } else unreachable;
            },
            '-' => {},
            '|' => {
                if (curr_dir == UP) {
                    sign = -1;
                } else if (curr_dir == DOWN) {
                    sign = 1;
                } else unreachable;
            },
            else => unreachable // we are in the main loop (because I know the input)
        }
        switch (curr_dir) {
            UP => curr_point[0] -= 1,
            RIGHT => curr_point[1] += 1,
            DOWN => curr_point[0] += 1,
            LEFT => curr_point[1] -= 1,
            else => unreachable
        }
    }

    std.log.debug("Area = {}", .{area});

}
