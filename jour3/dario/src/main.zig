const std = @import("std");
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

const CHARS_PER_LINE = 140;
const NUM_LINES = 140;

pub fn main() !void {

    var input :[NUM_LINES][CHARS_PER_LINE]u8 = undefined;

    var br = std.io.bufferedReader(std.io.getStdIn().reader());
    const stdin = br.reader();

    var sum_of_parts : u32 = 0;

    // Save the input in the input buffer
    for (0..NUM_LINES) |i| {
        _ = try stdin.readAll(&input[i]);
        _ = try stdin.readByte();
    }

    // Iterate over the input to find and parse numbers
    // num_start For each coordinate containing a number cache where the number started 
    var num_starts : [NUM_LINES][CHARS_PER_LINE]?usize = undefined;
    // nums: At the start of each number, cache the parsed number
    var nums : [NUM_LINES][CHARS_PER_LINE]?u32 = undefined;
    for (0..NUM_LINES) |linum| {
        var i : usize = 0;
        while (i < CHARS_PER_LINE) {
            defer i += 1;
            if (is_num(input[linum][i])) {
                // found a start of a number, need to find the end of it to parse it.
                const start = i;
                while (i < CHARS_PER_LINE and is_num(input[linum][i])) {
                    // opportunistically maintain the num_starts array
                    num_starts[linum][i] = start; 
                    i += 1;
                }
                // Don't forget to actually parse the number
                nums[linum][start] = std.fmt.parseInt(u32, input[linum][start..i], 10) catch unreachable;
                //correct index
                i -= 1;
            } else {
                num_starts[linum][i] = null;
            }
        }
    }

    // wtf, I don't know a one-liner to create an array of false.
    var num_added : [NUM_LINES][CHARS_PER_LINE]bool = undefined;
    for (0..NUM_LINES) |linum| {
        for (0..CHARS_PER_LINE) |i| {
            num_added[linum][i] = false;
        }
    }

    for (0..NUM_LINES) |linum| {
        for (0..CHARS_PER_LINE) |i| {
            const char = input[linum][i];
            if (!is_num(char) and char != '.') {
                // it is a special character
                var backing : [8][2]usize = undefined;
                const surs = surround(linum, i, &backing);
                // for each elements in it's surrounding
                for (surs) |sur| {
                    // if it's a number, get a "pointer" to the number's value
                    if (num_starts[sur[0]][sur[1]]) |num_start| {
                        // if the number wasn't added already
                        if (!num_added[sur[0]][num_start]) {
                            // add it and note it as added.
                            const adding = nums[sur[0]][num_start] orelse unreachable;
                            sum_of_parts += adding;
                            num_added[sur[0]][num_start] = true;
                        }
                    }
                }
            }
        }
    }

    try stdout.print("Sum of parts = {}\n", .{sum_of_parts});

}

fn is_num(char: u8) bool {
    return char <= '9' and char >= '0';
}

fn surround(linum : usize, i: usize, backing: *[8][2]usize) [][2]usize {
    var count : usize = 0;
    // One line up
    if (linum > 0 and i > 0) {
        backing[count] = [2]usize{linum - 1, i - 1};
        count += 1;
    }
    if (linum > 0) {
        backing[count] = [2]usize{linum - 1, i};
        count += 1;
    }
    if (linum > 0 and i < CHARS_PER_LINE - 1) {
        backing[count] = [2]usize{linum - 1, i + 1};
        count += 1;
    }
    // Same line
    if (i > 0) {
        backing[count] = [2]usize{linum, i - 1};
        count += 1;
    }
    if (i < CHARS_PER_LINE - 1) {
        backing[count] = [2]usize{linum, i + 1};
        count += 1;
    }
    // One line down
     if (linum < NUM_LINES - 1 and i > 0) {
        backing[count] = [2]usize{linum + 1, i - 1};
        count += 1;
    }
    if (linum < NUM_LINES - 1) {
        backing[count] = [2]usize{linum + 1, i};
        count += 1;
    }
    if (linum < NUM_LINES - 1 and i < CHARS_PER_LINE - 1) {
        backing[count] = [2]usize{linum + 1, i + 1};
        count += 1;
    }
    return backing[0..count];
}