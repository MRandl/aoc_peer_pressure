from collections import defaultdict

#part 1
def process(line):
    (winners, current) = line.split(":")[1].split("|")
    winners = [int(x) for x in winners.split() if x != ""]
    current = set([int(x) for x in current.split() if x != ""])

    len_of_intersection = len([x for x in winners if x in current])
    return 0 if len_of_intersection == 0 else 2 ** (len_of_intersection - 1)

with open("inputs/mathis.txt") as f:
    grid = f.readlines()
    res = sum([process(x) for x in grid])
        
print("solution 1 :", res)

#part 2
copies = defaultdict(lambda: 1)

def update_dict_with(line):
    index = int(''.join([x for x in line.split(":")[0] if x.isdigit()]))

    (winners, current) = line.split(":")[1].split("|")
    winners = [int(x) for x in winners.split() if x != ""]
    current = set([int(x) for x in current.split() if x != ""])

    len_of_intersection = len([x for x in winners if x in current])

    for i in range(index + 1, index + len_of_intersection + 1):
        copies[i] += copies[index]
    
with open("inputs/mathis.txt") as f:
    grid = f.readlines()
    for x in grid:
        update_dict_with(x)
    print("solution 2 :", sum([copies[x] for x in range(1, len(grid) + 1)]))
