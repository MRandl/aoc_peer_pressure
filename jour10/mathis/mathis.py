pipe2moves = {"|" : "NS", "-" : "EO", "L" : "NE", "J" : "NO", "7" : "SO", "F" : "SE", "." : ""}
opposite = {"N" : "S", "O" : "E", "E" : "O", "S" : "N"}

def find_start_pos(lines):
    s_x, s_y = -1, -1
    for i in range(len(lines[0])):
        for j in range(len(lines)):
            char = lines[j][i]
            if(char == "S"):
                return i, j

def follow_direction(direction, position, maxx = 140):
    x, y = position
    if direction == "N" and y > 0:
        return (x, y - 1)
    if direction == "E" and x < maxx - 1:
        return (x + 1, y)
    if direction == "S" and y < maxx - 1:
        return (x, y + 1)
    if direction == "O" and x > 0:
        return (x - 1, y)
    return None

def next_direction(position, coming_from, lines):
    x, y = position
    pipe = lines[y][x]
    legal_moves = pipe2moves[pipe]
    if not coming_from in legal_moves:
        return None
    return [x for x in legal_moves if x != coming_from][0]

def attempt_loop(i, j, direction, lines):
    positions = [(i, j)]
    current_position = follow_direction(direction, (i, j))
    while (current_position is not None) and (direction is not None) and current_position != (i,j):
        positions.append(current_position)
        coming_from = opposite[direction]
        direction = next_direction(current_position, coming_from, lines)
        current_position = follow_direction(direction, current_position)

    if current_position is None or direction is None:
        return None
    return positions

def find_area(loop): #idea from reddit : shoelace formula
    area = 0
    for i in range(-1, len(loop) - 1):
        prev_x, prev_y = loop[i]
        curr_x, curr_y = loop[i+1]
        area += (prev_y + curr_y) * (prev_x - curr_x) // 2
    
    area = area if area > 0 else - area
    return area - len(loop)//2 + 1

with open("input.txt", "r") as f:
    lines = f.read().splitlines()
    s_x, s_y = find_start_pos(lines)
    for direction in ["N", "E", "S", "O"]:
        loop = attempt_loop(s_x, s_y, direction, lines)
        if loop is not None:
            break

    print("Solution 1 :", len(loop)//2)
    print("Solution 2 :", find_area(loop))
    
    

