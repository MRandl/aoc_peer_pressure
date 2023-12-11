def find_empty(inputs, is_row):
    result = []
    for i in range(len(inputs if is_row else inputs[0])):
        row_or_col = inputs[i] if is_row else [inputs[j][i] for j in range(len(inputs))]
        if all([x == "." for x in row_or_col]):
            result.append(i)
    return result

def distance_between(pos1, pos2, empty_rows, empty_cols, multiplier):
    empty_cross_x = len([x for x in empty_rows if pos1[0] < x < pos2[0] or pos1[0] > x > pos2[0]])
    empty_cross_y = len([y for y in empty_cols if pos1[1] < y < pos2[1] or pos1[1] > y > pos2[1]])
    return abs(pos1[0] - pos2[0]) + abs(pos1[1] - pos2[1]) + (multiplier - 1) * (empty_cross_x + empty_cross_y)

def find_galaxies(inputs):
    galaxies_pos = []
    for i in range(len(inputs)):
        for j in range(len(inputs[0])):
            if inputs[i][j] == "#":
                galaxies_pos.append((i, j))
    return galaxies_pos

def galaxy_dists(galaxies, empty_rows, empty_cols, multiplier):
    sum_dist = 0
    for i in range(len(galaxies)):
        g1 = galaxies[i]
        for g2 in galaxies[i+1:]:
            dist = distance_between(g1, g2, empty_rows, empty_cols, multiplier)
            sum_dist += dist
    return sum_dist

with open("input.txt") as f:
    lines = f.read().splitlines()
    galaxies = find_galaxies(lines)
    empty_rows = find_empty(lines, True)
    empty_cols = find_empty(lines, False)

    print("Solution 1 :", galaxy_dists(galaxies, empty_rows, empty_cols, 2))
    print("Solution 2 :", galaxy_dists(galaxies, empty_rows, empty_cols, 1000000))
