const std = @import("std");
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

const CHARS_PER_LINE = 131;
const NUM_LINES = 131;
const DO_PRINTS = true;

pub fn main() !void {

    var input :[NUM_LINES][CHARS_PER_LINE]u8 = undefined;

    var args_iterator = std.process.args();
    _ = args_iterator.next(); // progam name
    const num_steps = try std.fmt.parseInt(u32, args_iterator.next().?, 10);

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

    for (0..num_steps) |i| {
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
        std.debug.print("State at step i = {}:\n", .{num_steps});
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

// Part 2:
// after 65 steps we complete the inner diamond
// every 131 additionnal steps we expand one square outwards.
// Let N be the number of times we expand one square outwards
//
// After 65 steps we cover half a square
// +-----+-----+-----
// |.....|.....|.....
// |.....|.....|.....
// |.....|.....|.....
// |.....|.....|.....
// |.....|.....|.....
// |-----+-----+-----
// |.....|..0..|.....
// |.....|.0.0.|.....
// |.....|0.0.0|.....
// |.....|.0.0.|.....
// |.....|..0..|.....
// +-----+-----+-----
// |.....|.....|.....
// |.....|.....|.....
// |.....|.....|.....
// |.....|.....|.....
// |.....|.....|.....
//
// after 131 additionnal steps (N = 1) we cover this diamond:
// +-----+-----+-----
// |.....|..0..|.....
// |.....|.0.0.|.....
// |.....|0.0.0|.....
// |....0|.0.0.|0....
// |...0.|0.0.0|.0...
// |-----+-----+-----
// |..0.0|.0.0.|0.0..
// |.0.0.|0.0.0|.0.0.
// |0.0.0|.0.0.|0.0.0
// |.0.0.|0.0.0|.0.0.
// |..0.0|.0.0.|0.0..
// +-----+-----+-----
// |...0.|0.0.0|.0...
// |....0|.0.0.|0....
// |.....|0.0.0|.....
// |.....|.0.0.|.....
// |.....|..0..|.....
//
// Which is (almost*) equivalent to 5 squares being covered:
// +-+-+-
// |.|O|.
// +-+-+-
// |O|E|O
// +-+-+-
// |.|O|.
//
// Where the O-squares are being covered with "odd" pattern (center plot is unexplored)
// and the E-squares are being covered with the "even" patten (center plot is explored)
//
// After 131 more steps (N = 2) we'll get:
// +-+-+-+-+-
// |.|.|O|.|.
// +-+-+-+-+-
// |.|O|E|O|.
// +-+-+-+-+-
// |O|E|O|E|O
// +-+-+-+-+-
// |.|O|E|O|.
// +-+-+-+-+-
// |.|.|O|.|.
//
// EXCEPT! There is the "almost*" previously mentionned. The outer layer does not perfectly form squares.
// This is because adjacent squares never have the same parity, therefore we can't add the incomplete outer squares
// together to form complete sqares.
// Therefore we have to account for the number of plots in the incomplete outer squares (which are always Odd-patterned).
//
// A more accurate representation for N = 2 would be:
// +-+-+-+-+-
// |.|.|w|.|.
// +-+-+-+-+-
// |.|q|E|e|.
// +-+-+-+-+-
// |a|E|O|E|d
// +-+-+-+-+-
// |.|y|E|c|.
// +-+-+-+-+-
// |.|.|x|.|.
//
// Since total_steps = 26501365 = 202300 * 131 + 65, we have a value of for our problem of N = 202300:
// with our N, the outer partial squares are going to be Odd. Don't get confused:
// For Even values of N, even-numbered rings are going to contain Odd-patterned squares.
//
// The total is going to be 1*(a+w+d+x) + (N-1)(q+e+c+y) + ODDS * O + EVENS * E
// - It can be useful to define the number of plots in an odd center diamond as C
// such that (a+w+d+x) = 4C + 2*(q+e+c+y)
// - And then we can say that (q+e+c+y) = O - C.
// Therefore the total is 4C + (N+1)(O - C) + ODDS * O + EVENS * E.
//
// Now we need to deternime the number of Even and Odd numbers of squares.
// These number of squares can be expressed as sums:
// ODDS = SUM(i=1..N/2, 4*(2i)) + 1 // number of blocks in even rings
// EVENS = SUMS(i=1..N/2, 4(2i-1)) // number of block in even rings
//
// What remains is to measure the value of C, E, and O
// which is the result of the program for part 1 for num_steps = 64, 130, and 131 respectively.


const N: u64 = 202300;
const C: u64 = 3682;
const E: u64 = 7474;
const O: u64 = 7407;

test "part2 evens/odds" {
    var odds: u64 = 0;
    for (1..N/2) |i| {
        odds += 8*i;
    }
    var evens: u64 = 0;
    for (1..N/2) |i| {
        evens += 4*(2*i-1);
    }

    const res = 4 * C + (N-1)*(O - C) + odds * O +  evens * E;
    std.debug.print("total = {}\n", .{res});

}