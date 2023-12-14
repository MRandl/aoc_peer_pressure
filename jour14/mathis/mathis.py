from itertools import count

def compute_shift(next): #computes how much a rock will move given what's next on its trajectory
    try:
        find_static = next.index('#')
    except ValueError:
        find_static = len(next)
    consider_subset = next[:find_static]
    return len([x for x in consider_subset if x == '.'])

def move_rocks(lines): #moves rocks towards east
    result = [["."] * len(lines[0]) for _ in range(len(lines))]
    for i in range(len(lines)):
        for j in range(len(lines[0])):
            if lines[i][j] == "O":
                result[i][compute_shift(lines[i][j:]) + j] = "O"
            elif lines[i][j] == "#":
                result[i][j] = "#"
    return result

def rotate(lines):
    return [list(row) for row in zip(*reversed(lines))] 

def iterate_four(lines):
    for _ in range(4):
        lines = rotate(lines)
        lines = move_rocks(lines)
    return lines

def score(lines, should_rotate = False):
    if should_rotate:
        lines = rotate(lines)
    result = 0
    for i in range(len(lines)):
        for j in range(len(lines[0])):
            if lines[i][j] == "O":
                result += j + 1
    return result

def to_string(lines):
    return '\n'.join([''.join(x) for x in lines])

with open("input.txt", "r") as f:
    lines = [list(l) for l in f.read().splitlines()]

    rotated_90 = rotate(lines)
    print("Solution 1 :", score(move_rocks(rotated_90)))

    
    #solution 2 : aim to find a loop in the consecutive states of the board
    seen = {}
    scores = []
    iteration = 0
    cached = to_string(lines)

    for iteration in count(0):
        seen[cached] = iteration
        scores.append(score(lines, True))
        lines = iterate_four(lines)
        cached = to_string(lines)
        if cached in seen:
            break
    
    first_seen = seen[cached]
    length_of_loop = iteration - first_seen
    final_index = first_seen + (1000000000 - first_seen) % length_of_loop
        
    print("Solution 2 :", scores[final_index])
