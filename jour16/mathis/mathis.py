mirrors = {"/" : {"N" : "E", "E" : "N", "S" : "O", "O" : "S"}, "\\" : {"N" : "O", "E" : "S", "S" : "E", "O" : "N"}}

def follow_direction(pos, direction, MAX_X = 110, MAX_Y = 110):
    x, y = pos
    if direction == "N" and x > 0:
        return (x - 1, y)
    if direction == "S" and x < MAX_X - 1:
        return (x + 1, y)
    if direction == "O" and y > 0:
        return (x, y - 1)
    if direction == "E" and y < MAX_Y - 1:
        return (x, y + 1)
    return None

def update_direction(pos, direction, grid):
    x, y = pos
    elem = grid[x][y]
    if elem == ".":
        return [direction]
    if elem == "/" or elem == "\\":
        return [mirrors[elem][direction]]
    if elem == "-" and (direction == "E" or direction == "O"):
        return [direction]
    if elem == "-":
        return ["E", "O"]
    if elem == "|" and (direction == "N" or direction == "S"):
        return [direction]
    if elem == "|":
        return ["S", "N"]

def follow_path(pos, direction, grid):
    to_follow = {(pos, direction)}
    explored = set()
    while(len(to_follow) > 0):
        elem = to_follow.pop()
        (p, d) = elem
        if elem not in explored:
            explored.add(elem)
            new_dirs = update_direction(p, d, grid)
            for new_dir in new_dirs:
                new_pos = follow_direction(p, new_dir)
                if new_pos is not None:
                    to_follow.add((new_pos, new_dir))
    return len({x[0] for x in explored})

def follow_all_paths(grid):
    maxx = max(0,    max([follow_path((x, 0), "E", grid) for x in range(len(grid))]))
    maxx = max(maxx, max([follow_path((0, y), "S", grid) for y in range(len(grid[0]))]))
    maxx = max(maxx, max([follow_path((x, len(grid[0]) - 1), "O", grid) for x in range(len(grid))]))
    maxx = max(maxx, max([follow_path((len(grid) - 1,    y), "N", grid) for y in range(len(grid[0]))]))

    return maxx

with open("input.txt", "r") as f:
    grid = f.read().splitlines()
    print("Solution 1 :", follow_path((0, 0), "E", grid))

    print("Solution 2 :", follow_all_paths(grid))
