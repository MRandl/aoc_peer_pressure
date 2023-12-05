def parse_map(maplines):
    parsed_lines = [
        l.split(" ") for l in maplines if "map" not in l
    ]  # dismiss map name and split liness on spaces
    return [
        [int(num) for num in l] for l in parsed_lines
    ]  # transform strings to numbers


def parse_seed_1(seed):
    return set(
        [(int(x), int(x)) for x in seed.split(" ")[1:]]
    )  # dismiss seeds header, parse numbers to int and turn into set

def parse_seed_2(seed):
    seed = [int(x) for x in seed.split(" ")[1:]]
    pairs = zip(seed[::2], [x - 1 for x in seed[1::2]])
    ranges = [(i, i + j) for (i, j) in pairs]
    return ranges


def apply_line_to_range(line, rang):
    (dst, src, lth) = line
    (r_start, r_end) = rang
    if src >= r_end or r_start >= src + lth:
        return []
    else:
        toret = []
        os = max(src, r_start)
        oe = min(src + lth, r_end)

        toret.append((os + dst - src, oe + dst - src))
        if os != r_start:
            toret.append((r_start, os))
        if oe != r_end:
            toret.append((oe, r_end))
        return toret

def best_mapping_for_range(rang, maps):
    if len(maps) == 0:
        return rang[0]
    else:
        for line in maps[0]: 
            candidates = apply_line_to_range(line, rang)
            if len(candidates) > 0:
                return min([best_mapping_for_range(candidates[0], maps[1:])] + [best_mapping_for_range(l, maps) for l in candidates[1:]])
        return best_mapping_for_range(rang, maps[1:])

with open("input.txt") as f:
    alldata = f.read().split("\n\n")
    seed1 = parse_seed_1(alldata[0])
    seed2 = parse_seed_2(alldata[0])
    allmaps = [parse_map(x.split("\n")) for x in alldata[1:]]

    res1 = min([best_mapping_for_range(rang, allmaps) for rang in seed1])
    print("solution 1 :", res1)

    res2 = min([best_mapping_for_range(rang, allmaps) for rang in seed2])
    print("solution 2 :", res2)
