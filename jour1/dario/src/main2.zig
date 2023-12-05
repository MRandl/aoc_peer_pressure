const std = @import("std");
const expect = @import("std").testing.expect;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();

    var num_lines:u64 = 0;
    var sum : u64 = 0;
    var curr_first : u8 = 0;
    var curr_last : u8 = 0;

    var sms = [_]ComplexSM{
        ComplexSM.new("one"),
        ComplexSM.new("two"),
        ComplexSM.new("three"),
        ComplexSM.new("four"),
        ComplexSM.new("five"),
        ComplexSM.new("six"),
        ComplexSM.new("seven"),
        ComplexSM.new("eight"),
        ComplexSM.new("nine"),
    };

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

        for (&sms, 0..) |*sm, sm_idx| {
            if (sm.accept(curr_char)) {
                const s2c = @as(u8,@intCast(sm_idx + 1)) + '0';
                if (curr_first == 0) {
                    curr_first = s2c;
                }
                curr_last = s2c;
            }
        }
        
        if (is_num(curr_char)) {
            if (curr_first == 0) {
                curr_first = curr_char;
            }
            curr_last = curr_char;
        }
    }
}

const StateMachine = struct {
    const Self = @This();
    idx: usize,
    string: []const u8,


    fn new(string: []const u8) Self {
        return Self {.idx = 0, .string = string};
    }

    fn accept(self: *Self, char : u8) bool {
        if (char == self.string[self.idx]) {
            self.idx += 1;
            if (self.idx == self.string.len) {
                self.idx = 0;
                return true;
            }
            return false;
        } else {
            self.idx = 0;
            return false;
        }
    }

    fn reset(self: *Self) void {
        self.idx = 0;
    }
};

//dirty trick to make nine work:
//have two state machines and reset one of them
//everytime we see the first character. Only works
//because there is only one repetition of the first character.
// YOLO.
const ComplexSM = struct {
    const Self = @This();
    sm0: StateMachine,
    sm1: StateMachine,
    reset_char: u8,
    curr_reset: u1,

    fn new(string: []const u8) Self {
        return Self {
            .sm0 = StateMachine.new(string),
            .sm1 = StateMachine.new(string),
            .reset_char = string[0],
            .curr_reset = 0};
    }

    fn accept(self: *Self, char : u8) bool {
        if (char == self.reset_char) {
            if (self.curr_reset == 0) {
                self.sm0.reset();
            } else {
                self.sm1.reset();
            }
            self.curr_reset = 1 - self.curr_reset;
        }
        const a1 = self.sm0.accept(char);
        const a2 = self.sm1.accept(char);
        return a1 or a2;
    }

};

fn is_num(char : u8) bool {
    return '0' <= char and char <= '9';
}

fn to_int(char : u8) u64 {
    return @as(u64, @intCast(char - '0'));
}
