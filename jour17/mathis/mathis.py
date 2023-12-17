import networkx as nx

MAX_X = 141
MAX_Y = 141

# history is the "state" of the path. History is the amount of last moves in the same direction.
# history = 4*A + B where A = amount of steps, B = direction (0, 1, 2, 3) for cardinal directions (N, E, S, O)
# change_history takes the next direction (dirr) and generates the next history, if the new direction is legal
def change_history(hist, dirr, ultra_crucible):
    amount    = hist // 4
    direction = hist %  4
    if (not ultra_crucible) and amount == 3 and direction == dirr:
        return None
    if (ultra_crucible) and ((amount >= 10 and direction == dirr) or (amount < 4 and direction != dirr)):
        return None
    elif {dirr, direction} == {0, 2} or {dirr, direction} == {1, 3}: # no going back!
        return None
    elif direction == dirr:
        return (amount + 1) * 4 + dirr
    else:
        return 4 + dirr

# each position (x, y, history) has at most 4 neighbors. check if out of bounds or illegal crucible move
def neighbors(x, y, history, ultra_crucible):
    res = []
    if x > 0: # try moving north etc
        n_hist = change_history(history, 0, ultra_crucible)
        if n_hist is not None:
            res.append((x - 1, y, n_hist))
    if y > 0:
        n_hist = change_history(history, 3, ultra_crucible)
        if n_hist is not None:
            res.append((x, y - 1, n_hist))
    if x < MAX_X - 1:
        n_hist = change_history(history, 2, ultra_crucible)
        if n_hist is not None:
            res.append((x + 1, y, n_hist))
    if y < MAX_Y - 1:
        n_hist = change_history(history, 1, ultra_crucible)
        if n_hist is not None:
            res.append((x, y + 1, n_hist))
    return res

# generate several copies of the grid, one for each legal history. 
# add an edge between two nodes (x, y, hist1) and (a, b, hist2) iff (x, y) and (a, b) are neighbors
# in the original grid, and hist2 equals (hist1 followed by a move from (x, y) to (a, b))
# then, we only need to find a minimal path from (0, 0, empty history) to any (MAX_X, MAX_Y, hist) with hist any history
def generate_graph_and_run(nums, ultra_crucible):
    limit = 16 if not ultra_crucible else 44
    g = nx.DiGraph()
    for x in range(MAX_X):
        for y in range(MAX_Y):
            for hist in range(limit):
                g.add_node((x,y,hist))

    for x in range(MAX_X):
        for y in range(MAX_Y):
            for hist in range(limit):
                for neigh in neighbors(x, y, hist, ultra_crucible):
                    g.add_edge((x, y, hist), neigh, weight = nums[neigh[0]][neigh[1]])
    
    path_lengths = []
    for i in [1, 2] if ultra_crucible else [0]:
        #contains every single legal path that starts from (0,0,i)
        TURBOMEGAPATHS_AAAAAAH = nx.shortest_path_length(g, (0, 0, i), weight = "weight") 
        for depth in range(5, limit):
            if (MAX_X - 1, MAX_Y - 1, depth) in TURBOMEGAPATHS_AAAAAAH:
                path_lengths.append(TURBOMEGAPATHS_AAAAAAH[(MAX_X - 1, MAX_Y - 1, depth)])

    return min(path_lengths)

with open("input.txt") as f:
    lines = f.read().splitlines()
    nums = [[int(x) for x in l] for l in lines]
    
    print("Solution 1 :", generate_graph_and_run(nums, False))
    print("Solution 2 :", generate_graph_and_run(nums, True))
