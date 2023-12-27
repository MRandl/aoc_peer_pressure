const std = @import("std");
const stdout = std.io.getStdOut().writer();
const expect = std.testing.expect;

const DO_PRINTS = true;

pub fn main() !void {

    var args_iterator = std.process.args();
    _ = args_iterator.next(); // progam name

    var br = std.io.bufferedReader(std.io.getStdIn().reader());
    const stdin = br.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    // Hold all the blocks
    var blocks = try std.ArrayList(Block).initCapacity(allocator, 1470);

    // Init the datastructure for holding cubes
    var columns: Columns = undefined;
    for (0..10) |x| {
        for (0..10) |y|{
            columns[x][y] = std.ArrayList(*Cube).init(allocator);
        }
    }

    // Iterate over all blocks to get
    while (try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 16) orelse null) |line| {
        defer allocator.free(line);
        
        // too complicated bullshit to get an iterator over all the cubes for this line.
        var ends_iterator = std.mem.splitScalar(u8, line, '~');
        const cube1 = try parse_cube(ends_iterator.next().?);
        const cube2 = try parse_cube(ends_iterator.next().?);
        const dim = find_dimension(cube1, cube2);
        const num_cubes = 
            if (cube1[dim] < cube2[dim]) 
                cube2[dim] - cube1[dim] + 1 
            else 
                cube1[dim] - cube2[dim] + 1;
        const base_cube = 
            if (cube1[dim] < cube2[dim]) 
                cube1 
            else
                cube2;

        // Create the Block
        const block = try blocks.addOne();
        block.fallen = false;
        block.cannot_be_removed = false;
        const cubes : []Cube = try allocator.alloc(Cube, num_cubes);
        block.cubes = cubes;
        for (cubes, 0..) |*cube, i| {
            cube.block = block;
            cube.coords = base_cube;
            cube.coords[dim] += i;

            // Add the cubes to the column heap
            try columns[cube.coords[X]][cube.coords[Y]].append(cube);
        }

    }

    // Sort the cubes in each colunm
    for (0..10) |x| {
        for (0..10) |y|{
            std.mem.sort(*Cube, columns[x][y].items, {}, Cube.lower);
        }
    }

    // Make the blocks fall as much as possible
    for (0..10) |x| {
        for (0..10) |y|{
            for (columns[x][y].items) |cube| {
                fall_block(cube.block, columns);
            }
        }
    }

    // Count the blocks that can be removed:
    var count_can_be_removed = blocks.items.len;
    for (blocks.items) |*block| {
        if (block.cannot_be_removed) {
            count_can_be_removed -= 1;
        }
    }

    std.debug.print("The amount of blocks that can be removed is {}\n", .{count_can_be_removed});
}

const X : usize = 0;
const Y : usize = 1;
const Z : usize = 2;

const Columns = [10][10]std.ArrayList(*Cube);

fn parse_cube(str : []const u8) ![3]usize {
    var dim_iterator = std.mem.splitScalar(u8, str, ',');
    var coords : [3]usize = undefined;
    for (0..3) |d| {
        const dim = dim_iterator.next().?;
        coords[d] = try std.fmt.parseInt(usize, dim, 10);
    }
    return coords;
}

fn find_dimension(coord1 : [3]usize, coord2 : [3]usize) usize {
    for (0..3) |dim| {
        if (coord1[dim] != coord2[dim]) {
            return dim;
        }
    }
    return 0;
}

const Cube = struct {
    coords : [3]usize,
    block : *Block,

    fn lower(context: void, a:*Cube, b:*Cube) bool {
        _ = context;
        return std.math.order(a.coords[Z], b.coords[Z]) == std.math.Order.lt;
    }

    fn higher(comptime context: type, a:*Cube, b:*Cube) std.math.Order {
        _ = context;
        return std.math.order(a.coords[Z], b.coords[Z]);
    }
};

const Block = struct {
    fallen: bool,
    cannot_be_removed: bool,
    cubes: []Cube,
};

// Makes the block associated to the cube fall as much as possible
// This also makes the blocks it rests on fall as possible
// Sets the block.fallen flag once it's fallen
// columns is the datastructure storing cubes in ordered columns
fn fall_block(block: *Block, columns: Columns) void {
    if (block.fallen) return;

    // check that the block is not vertical
    if (block.cubes[0].coords[Z] != block.cubes[block.cubes.len-1].coords[Z]) {
        fall_block_vertical(block, columns);
        return;
    }
    
    var max_height: ?usize = null;

    // variable related to the problem
    var only_one_supporting : ?*Block = null;

    // recursively fall blocks and determine the maximum height of lower blocks
    for (block.cubes) |*cube| {
        const column = columns[cube.coords[X]][cube.coords[Y]];
        // Revisit: index can sometimes be cached
        const index = find_index(cube, column);
        if (index > 0) {
            const lower_cube = column.items[index-1];
            fall_block(lower_cube.block, columns);
            if (max_height == null) {
                max_height = lower_cube.coords[Z];
                only_one_supporting = lower_cube.block;
            } else if (lower_cube.coords[Z] > max_height.?) {
                max_height = lower_cube.coords[Z];
                only_one_supporting = lower_cube.block;
            } else if (lower_cube.coords[Z] == max_height.?) {
                if (only_one_supporting) |previous| {
                    if (lower_cube.block != previous) {
                        only_one_supporting = null;
                    }
                }
            }
        }
    }

    // Update the cannot_be_removed property
    if (only_one_supporting) |supporting| {
        supporting.cannot_be_removed = true;
    }

    // Max height determined, lower the height of the current block
    // Note that this should not change the ordering of the blocks
    for (block.cubes) |*cube| {
        if (max_height) |max| {
            cube.coords[Z] = max + 1;
        } else {
            cube.coords[Z] = 0;
        }
    }
    block.fallen = true;
}

// special case for when it is a vertical block
// similar to fall_block
fn fall_block_vertical(block: *Block, columns: Columns) void {
    var max_height: ?usize = null;

    // variable related to the problem
    var only_one_supporting : ?*Block = null;

    // By construction, the firt block is the lowest.
    for (block.cubes[0..1]) |*cube| {
        const column = columns[cube.coords[X]][cube.coords[Y]];
        // Revisit: index can sometimes be cached
        const index = find_index(cube, column);
        if (index > 0) {
            const lower_cube = column.items[index-1];
            fall_block(lower_cube.block, columns);
            max_height = lower_cube.coords[Z];
            only_one_supporting = lower_cube.block;
        }
    }

    // Update the cannot_be_removed property
    if (only_one_supporting) |supporting| {
        supporting.cannot_be_removed = true;
    }

    // Max height determined, lower the height of the current block
    // Note that this should not change the ordering of the blocks
    for (block.cubes, 0..) |*cube,i| {
        if (max_height) |max| {
            cube.coords[Z] = max + 1 + i;
        } else {
            cube.coords[Z] = i;
        }
    }
    block.fallen = true;
}

fn find_index(cube: *Cube, column: std.ArrayList(*Cube)) usize {
    const compareFn: fn(context: type, key: *Cube, mid_item: *Cube) std.math.Order = Cube.higher;
    return std.sort.binarySearch(*Cube, cube, column.items, void, compareFn).?;
}

