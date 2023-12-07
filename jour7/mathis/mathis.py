card_value = {"2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, \
    "9": 9, "10": 10, "T": 11, "J": 12, "Q": 13, "K": 14, "A": 15}
hand_to_type = { (5,) : "five", (1, 4) : "four", (2, 3) : "full", (1, 1, 3) : "three", \
    (1, 2, 2) : "two", (1, 1, 1, 2) : "one", (1, 1, 1, 1, 1) : "high" }

def find_type(hand, count_jokers):
    kind_counts = {}
    for char in hand:
        kind_counts[char] = kind_counts.get(char, 0) + 1

    if count_jokers:
        joker_counts = kind_counts.get("J", 0)
        if "J" in kind_counts:
            del kind_counts["J"]
        if(len(kind_counts) == 0):
            return "five"
        kind_counts[max(kind_counts, key=kind_counts.get)] += joker_counts
    
    kind_counts = tuple(sorted(list(kind_counts.values())))
    return hand_to_type[kind_counts]

def solve(lines, count_jokers):
    card_value["J"] = 1 if count_jokers else 12
    hands_by_types = {key:[] for key in hand_to_type.values()}

    for line in lines:
        hand, bet = line.split()
        sort_value = [card_value[card] for card in hand]
        hands_by_types[find_type(hand, count_jokers)].append((sort_value, hand, int(bet)))

    final_sorted = []
    for typpe in hands_by_types.keys():
        hands_by_types[typpe].sort(key=lambda x: x[0], reverse=True)
        final_sorted += hands_by_types[typpe]

    bets = zip([x[2] for x in final_sorted], range(len(final_sorted), 0, -1))
    return sum([x * y for x, y in bets])

with open("input.txt") as f:
    lines = f.readlines()
    print("solution 1 :", solve(lines, False))
    print("solution 2 :", solve(lines, True))
