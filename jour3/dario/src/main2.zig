const std = @import("std");
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

const CHARS_PER_LINE = 140;
const NUM_LINES = 140;

pub fn main() !void {

    var input :[NUM_LINES][CHARS_PER_LINE]u8 = undefined;

    var br = std.io.bufferedReader(std.io.getStdIn().reader());
    const stdin = br.reader();

    var sum_of_gears : u32 = 0;

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

    for (0..NUM_LINES) |linum| {
        for (0..CHARS_PER_LINE) |i| {
            const char = input[linum][i];
            if (char == '*') {
                // it is a gear character
                var backing : [8][2]usize = undefined;
                const surs = surround(linum, i, &backing);
                // for each elements in it's surrounding
                var num1: ?u32 = null;
                var num2: ?u32 = null;
                var last_starting: ?[2]usize = null;
                var overflow = false;
                for (surs) |sur| {
                    // if it's a number, get a "pointer" to the number's value
                    if (num_starts[sur[0]][sur[1]]) |num_start| {
                        // ignore numbers that we've already seen for this gear.
                        if (last_starting != null and sur[0] == last_starting.?[0] and num_start == last_starting.?[1]) {
                            continue;
                        }
                        // add it and note it as added.
                        const adding = nums[sur[0]][num_start] orelse unreachable;
                        if (num1 == null) {
                            num1 = adding;
                            last_starting = [_]usize{sur[0], num_start};
                            std.debug.print("({})", .{adding});
                            continue;
                        }
                        if (num2 == null) {
                            num2 = adding;
                            last_starting = [_]usize{sur[0], num_start};
                            std.debug.print("({})", .{adding});
                            continue;
                        }
                        overflow = true;
                        std.debug.print("Gear overlow on {}\n", .{adding});
                    }
                }
                if (num1 != null and num2 != null and !overflow) {
                    sum_of_gears += num1.? * num2.?;
                    std.debug.print("Gear added with {} and {}\n", .{num1.?, num2.?});
                } else {
                    std.debug.print("Gear discarded with {?} and {?} ({})\n", .{num1, num2, overflow});
                }
            }
        }
    }

    try stdout.print("Sum of gears = {}\n", .{sum_of_gears});

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

test "surround" {
    var backing: [8][2]usize = undefined;
    std.debug.print("surround of 138,7 = ", .{});
    for (surround(138, 7, &backing)) |coord| {
        std.debug.print("[{},{}], ", .{coord[0], coord[1]});
    } 
    std.debug.print("\n", .{});
    try std.testing.expect(surround(1, 1, &backing).len == 8);
    try std.testing.expect(surround(0, 0, &backing).len == 3);
    try std.testing.expect(surround(0, 4, &backing).len == 5);
    try std.testing.expect(surround(4, 0, &backing).len == 5);
    try std.testing.expect(surround(139, 0, &backing).len == 3);
    try std.testing.expect(surround(0, 139, &backing).len == 3);
    try std.testing.expect(surround(139, 1, &backing).len == 5);
    try std.testing.expect(surround(1, 139, &backing).len == 5);
    try std.testing.expect(surround(139, 139, &backing).len == 3);
    try std.testing.expect(surround(138, 5, &backing).len == 8);
    try std.testing.expect(surround(5, 138, &backing).len == 8);
}