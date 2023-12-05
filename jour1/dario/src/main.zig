const std = @import("std");
const expect = @import("std").testing.expect;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();

    var num_lines:u64 = 0;
    var sum : u64 = 0;
    var curr_first : u8 = 0;
    var curr_last : u8 = 0;
    while (true) {
        const curr_char : u8 = stdin.readByte() catch 0;
        if (curr_char == 0 or curr_char == '\n') {
            if (curr_first != 0) {
                sum += 10 * to_int(curr_first) + to_int(curr_last);
            }

            if (curr_char == 0) {
                std.debug.print("{d}\n", .{sum});
                std.os.exit(0);
            }

            curr_first = 0;
            curr_last = 0;
            num_lines += 1;

            continue;
        }
        
        if (is_num(curr_char)) {
            if (curr_first == 0) {
                curr_first = curr_char;
            }
            curr_last = curr_char;
        }
    }
}

fn is_num(char : u8) bool {
    return '0' <= char and char <= '9';
}

fn to_int(char : u8) u64 {
    return @as(u64, @intCast(char - '0'));
}
