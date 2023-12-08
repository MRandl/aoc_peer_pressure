from math import lcm

def simulate_position(pos, directions, mapp, index):
    return mapp[pos][0] if(directions[(index) % len(directions)] == "L") else mapp[pos][1]

def simulate_until_cond(pos, direction, mapp, condition):
    index = 0
    while not condition(pos):
        pos = simulate_position(pos, directions, mapp, index)
        index += 1
    return index

def find_ghost_intersection(start_ghost, direction, mapp):
    #trick = ghost run in circles of size multiple of len(direction). greedy stop on first Z + lcm works
    ghosts_first_hit = [simulate_until_cond(x, direction, mapp, lambda x: x[2] == "Z") for x in start_ghost]
    print(ghosts_first_hit, [x / len(direction) for x in ghosts_first_hit]) 
    return lcm(*ghosts_first_hit)

with open("input.txt", "r") as f:
    lines = f.read().splitlines()
    directions = lines[0]

    mapp = dict()
    for x in lines[2:]: # parse lines
        mapp[x[:3]] = (x[7:10], x[12:15]) # src -> (dst_l, dst_r)

    start_1 = "AAA"
    ans1 = simulate_until_cond(start_1, directions, mapp, lambda x : x == "ZZZ")
    print("solution 1 :", ans1)

    start_2 = [x for x in mapp.keys() if x.endswith("A")]
    ans2 = find_ghost_intersection(start_2, directions, mapp)
    print("solution 2 :", ans2)
