const std = @import("std");
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

const CHARS_PER_LINE = 131;
const NUM_LINES = 131;
const NUM_STEPS = 64;
const DO_PRINTS = false;

pub fn main() !void {

    var input :[NUM_LINES][CHARS_PER_LINE]u8 = undefined;

    var br = std.io.bufferedReader(std.io.getStdIn().reader());
    const stdin = br.reader();

    var sum_of_gears : u32 = 0;
    _ = sum_of_gears;

    // Save the input in the input buffer
    for (0..NUM_LINES) |i| {
        _ = try stdin.readAll(&input[i]);
        _ = try stdin.readByte();
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var start_point : [2]usize = undefined;

    for (input, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (char == 'S') {
                start_point = [_]usize{i, j};
            }
        }
    }

    input[start_point[0]][start_point[1]] = '.';
    
    // these two variables should not be used directly
    var plot_set1 = std.AutoHashMap([2]usize, void).init(allocator);
    var plot_set2 = std.AutoHashMap([2]usize, void).init(allocator);

    // use these variables instead
    var curr_state = &plot_set1;
    var next_state = &plot_set2;

    try curr_state.putNoClobber(start_point, {});

    for (0..NUM_STEPS) |i| {
        if (DO_PRINTS) {
            std.debug.print("State at step i = {}:\n", .{i});
            print_state(&input, curr_state);
        }

        var plots_iterator = curr_state.keyIterator();

        while (plots_iterator.next()) |plot| {
            var backing: [4][2]usize = undefined;
            const sur = surround(plot[0], plot[1], &backing);
            for (sur) |new_plot| {
                if (input[new_plot[0]][new_plot[1]] == '.') {
                    try next_state.put(new_plot, {});
                }
            }
        }

        const temp = next_state;
        next_state = curr_state;
        curr_state = temp;
        next_state.clearRetainingCapacity();
    }

    if (DO_PRINTS) {
        std.debug.print("State at step i = {}:\n", .{NUM_STEPS});
        print_state(&input, curr_state);
    }

    std.debug.print("Number of plots reached = {}\n", .{curr_state.count()});
}

fn surround(linum : usize, i: usize, backing: *[4][2]usize) [][2]usize {
    var count : usize = 0;
    // One line up
    if (linum > 0) {
        backing[count] = [2]usize{linum - 1, i};
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
    if (linum < NUM_LINES - 1) {
        backing[count] = [2]usize{linum + 1, i};
        count += 1;
    }
    return backing[0..count];
}

fn print_state(input: *[NUM_LINES][CHARS_PER_LINE]u8, state: *std.AutoHashMap([2]usize, void)) void {
    var output: [NUM_LINES][CHARS_PER_LINE]u8 = undefined;
    std.mem.copy([CHARS_PER_LINE]u8, &output, input);
    var iterator = state.keyIterator();
    while (iterator.next()) |plot| {
        output[plot[0]][plot[1]] = 'O';
    }
    for (output) |line| {
        std.debug.print("{s}\n", .{line});
    }
}