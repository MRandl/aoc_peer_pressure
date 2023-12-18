num2dir = {"0" : "R", "1" : "D", "2" : "L", "3" : "U"}

def update_position(curr, dirr, amount):
    x, y = curr
    if dirr == "U":
        return (x - amount, y)
    elif dirr == "D":
        return (x + amount, y)
    elif dirr == "R":
        return (x, y + amount)
    else:
        return (x, y - amount)

def parse_loop(lines, colors_matter):
    current = (0, 0)
    positions = []
    for line in lines:
        dirr, amount, color = line.split()
        if not colors_matter:
            new_pos = update_position(current, dirr, int(amount))
        else:
            dirr = color[-2]
            amount_hex = color[2:-2]
            new_pos = update_position(current, num2dir[dirr], int(amount_hex, 16))
        positions.append(new_pos)
        current = new_pos
    return positions

def find_area(loop):
    area = 0
    loop_len = 0
    for i in range(-1, len(loop) - 1):
        prev_x, prev_y = loop[i]
        curr_x, curr_y = loop[i+1]
        loop_len += abs(prev_x - curr_x) + abs(prev_y - curr_y)
        area += (prev_y + curr_y) * (prev_x - curr_x) // 2
    
    area = area if area > 0 else - area
    return area + loop_len//2 + 1

with open("input.txt") as f:
    lines = f.read().splitlines()
    
    loop = parse_loop(lines, False)
    print("Solution 1 : {}".format(find_area(loop)))
    loop = parse_loop(lines, True)
    print("Solution 1 : {}".format(find_area(loop)))