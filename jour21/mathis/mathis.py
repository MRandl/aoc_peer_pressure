import networkx as nx
import numpy as np 

def find_reachable(g, start, limit = 64):
    TURBOMEGAPATHS_AAAAAAH = nx.shortest_path_length(g, start) 
    return len({k for k,v in TURBOMEGAPATHS_AAAAAAH.items() if v <= limit and v % 2 == limit % 2})


def neighbors(x, y, lines, MAX_X = 131, MAX_Y = 131):
    ret = []
    if x > 0 and lines[x - 1, y] == 1:
        ret.append((x - 1, y))
    if y > 0 and lines[x, y - 1] == 1:
        ret.append((x, y - 1))
    if x < MAX_X - 1 and lines[x + 1, y] == 1:
        ret.append((x + 1, y))
    if y < MAX_Y - 1 and lines[x, y + 1] == 1:
        ret.append((x, y + 1))
    return ret

with open("input.txt", "r") as f:
    str_lines = f.read().splitlines()
    lines = np.array([[1 if x != "#" else 0 for x in l] for l in str_lines])
    g = nx.DiGraph()
    s = (0, 0)

    for x in range(len(lines)):
        for y in range(len(lines[0])):
            g.add_node((x,y))
            if str_lines[x][y] == "S":
                s = (x, y)
    
    for x in range(len(lines)):
        for y in range(len(lines[0])):
            for neigh in neighbors(x, y, lines):
                g.add_edge((x, y), neigh)

    print("Solution 1 :", find_reachable(g, s))

    # part 2 : given up. used idea from https://www.reddit.com/r/adventofcode/comments/18nevo3/comment/keaiiq7/
    # the solution is to notice that in the input, S is in an empty row and column + there is a fat rhombus around S + the edge nodes are free
    # then, 26501365 = 202300 * 131 + 65 so we only need to count the amount of rhombuses that we traverse, 
    # which is quadratic.
    # quadratic functions can be determined from 3 (x, y) pairs, so we get:

    lines = np.array(lines)
    lines = np.tile(lines, (5, 5)) # spawn 25 copies of the grid next to each other to 'simulate infinity'

    g = nx.DiGraph()
    s = (2 * 131 + 65, 2 * 131 + 65) # s is in the middle

    for x in range(len(lines)):
        for y in range(len(lines[0])):
            g.add_node((x,y))

    for x in range(len(lines)):
        for y in range(len(lines[0])):
            for neigh in neighbors(x, y, lines, MAX_X= 5*131, MAX_Y= 5*131):
                g.add_edge((x, y), neigh)

    y1 = find_reachable(g, s, limit = 65 + 0 * 131)
    y2 = find_reachable(g, s, limit = 65 + 1 * 131)
    y3 = find_reachable(g, s, limit = 65 + 2 * 131)

    n = 26501365//131 # (= 202300)
    print("Solution 2 :", y1 + n * (y2 - y1) + (n * (n-1) // 2*((y3 - 2*y2 + y1))))
