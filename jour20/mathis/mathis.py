from collections import deque
from math import lcm

class Broadcaster:
    def __init__(self, dst, name):
        self.dst = dst
        self.name = name

    def rcv(self, src, pulse_lvl):
        assert not pulse_lvl
        return [(False, self.name, x) for x in self.dst]

    def reset(self):
        pass

class FlipFlop:
    def __init__(self, dst, name):
        self.dst = dst
        self.name = name
        self.state = False

    def rcv(self, src, pulse_lvl):
        if not pulse_lvl:
            self.state = not self.state
            return [(self.state, self.name, x) for x in self.dst]
        return []

    def reset(self):
        self.state = False

class Conjunction:
    def __init__(self, dst, name, prev):
        self.dst = dst
        self.name = name
        self.state = {k:False for k in prev}

    def rcv(self, src, pulse_lvl):
        self.state[src] = pulse_lvl
        if all(self.state.values()):
            return [(False, self.name, x) for x in self.dst]
        return [(True, self.name, x) for x in self.dst]

    def reset(self):
        for k in self.state.keys():
            self.state[k] = False

def find_prevs_of_conjunctions(conjs, names):
    previouses = {k:[] for k in conjs}
    for conj in conjs:
        for (src, dsts) in names:
            if src[0] == "&" or src[0] == "%":
                src = src[1:]
            if conj in dsts:
                previouses[conj].append(src)
    return previouses

def run_sim(circuits, prev):
    to_run = deque([(False, "", "broadcaster")])
    amount_of_hgh = 0
    amount_of_low = 0
    hit_targets = []
    while len(to_run) > 0:
        (level, src, dst) = to_run.popleft()
        if level:
            amount_of_hgh += 1
        else:
            amount_of_low += 1
        if dst in circuits:
            to_send = circuits[dst].rcv(src, level)
            to_run.extend(to_send)
        if dst == prev and level:
            hit_targets.append(src)
    return (amount_of_hgh, amount_of_low, hit_targets)
    
with open("input.txt", "r") as f:
    lines = f.read().splitlines()
    names = [x.split(" -> ") for x in lines]
    names = [(x, y.split(", ")) for (x, y) in names]
    conjunctions = [x[1:] for (x, _) in names if x[0] == "&"]
    prevs = find_prevs_of_conjunctions(conjunctions, names)

    circuits = dict()
    for (name, dsts) in names:
        if name[0] == "&":
            circuits[name[1:]] = Conjunction(dsts, name[1:], prevs[name[1:]])
        elif name[0] == "%":
            circuits[name[1:]] = FlipFlop(dsts, name[1:])
        else:
            assert name == "broadcaster"
            circuits[name] = Broadcaster(dsts, "broadcaster")

    high_lows = [run_sim(circuits, None) for _ in range(1000)]
    highs = sum([x[0] for x in high_lows])
    lows  = sum([x[1] for x in high_lows])
    print("Solution 1 :", str(highs * lows))

    [c.reset() for c in circuits.values()]

    #part 2 : rx is connected only to one previous node and the nodes even before that have no cycle offset
    final = [k[1:] for k, v in names if "rx" in v][0]

    previouses_hits = {k[1:]:0 for k, v in names if final in v}
    count = 0
    while not all(v != 0 for v in previouses_hits.values()):
        count += 1
        (_, _, hits) = run_sim(circuits, final)
        for hit in hits:
            if previouses_hits[hit] == 0:
                previouses_hits[hit] = count
    print("Solution 2 :", lcm(*previouses_hits.values()))
