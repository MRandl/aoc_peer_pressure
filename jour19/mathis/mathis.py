import itertools

letter2index = {"x" : 0, "m" : 1, "a" : 2, "s" : 3}

def parse_commands(lines):
    commands = dict()
    for line in lines:
        algo = []
        name, body = line.split("{")
        body = body[:-1].split(',')
        for branch in body[:-1]:
            check, goto = branch.split(":")
            varname = check[0]
            comp_symbol = check[1]
            num = int(check[2:])
            comparator = (comp_symbol, num)
            algo.append({"varname" : varname, "comp" : comparator, "goto" : goto})
        algo.append(body[-1])
        commands[name] = algo
    return commands

def parse_gears(lines):
    gears = []
    for line in lines:
        line = line[1:-1] # remove {}
        parsed_line = [int(attrib.split("=")[1]) for attrib in line.split(",")] #discard var names, retain values as ints
        gears.append(parsed_line)
    return gears

def run_command(gear, command):
    for subcommand in command[:-1]:
        index2check = letter2index[subcommand["varname"]]

        if subcommand["comp"][0] == "<" and gear[index2check] < subcommand["comp"][1]:
            return subcommand["goto"]
        if subcommand["comp"][0] == ">" and gear[index2check] > subcommand["comp"][1]:
            return subcommand["goto"]
    return command[-1]

def is_accepted(gear, commands):
    current_command = "in"
    while current_command != "A" and current_command != "R":
        current_command = run_command(gear, commands[current_command])
    return current_command == "A"

#part 2
def range_is_invalid(ranger):
    return any(x[1] < x[0] for x in ranger)

def range_split_once(initial_range, command):
    for subcommand in command[:-1]:
        index2check = letter2index[subcommand["varname"]]

        if subcommand["comp"][0] == "<" and initial_range[index2check][0] < subcommand["comp"][1]:
            gotorange = [initial_range[i] if i != index2check else (initial_range[index2check][0], subcommand["comp"][1] - 1) for i in range(4)]
            leftrange = [initial_range[i] if i != index2check else (subcommand["comp"][1], initial_range[index2check][1]) for i in range(4)]
            if range_is_invalid(leftrange):
                leftrange = None
            return gotorange, subcommand["goto"], leftrange

        if subcommand["comp"][0] == ">" and initial_range[index2check][1] > subcommand["comp"][1]:
            gotorange = [initial_range[i] if i != index2check else (subcommand["comp"][1] + 1, initial_range[index2check][1]) for i in range(4)]
            leftrange = [initial_range[i] if i != index2check else (initial_range[index2check][0], subcommand["comp"][1]) for i in range(4)]
            if range_is_invalid(leftrange):
                leftrange = None
            return gotorange, subcommand["goto"], leftrange

    return initial_range, command[-1], None

def range_split_all(initial_range, command):
    left = initial_range
    togo = []
    while left is not None:
        diverted, goto, left = range_split_once(left, command)
        togo.append((diverted, goto))
    return togo

def len_of_range(r) : 
    return (r[0][1] - r[0][0] + 1) * (r[1][1] - r[1][0] + 1) * (r[2][1] - r[2][0] + 1) * (r[3][1] - r[3][0] + 1)

def find_range_valid_count(commands):
    torun = [([(1, 4000) for _ in range(4)], "in")]
    
    count = 0
    while len(torun) > 0:
        nextt = [range_split_all(r, commands[c]) for r, c in torun]
        nextt = list(itertools.chain.from_iterable(nextt))
        count += sum([len_of_range(r) for r, c in nextt if c == "A"])
        torun = [(r, c) for r, c in nextt if c != "A" and c != "R"]

    return count

with open("input.txt", "r") as f:
    commandlines, gearlines = f.read().split("\n\n")
    commandlines = commandlines.splitlines()
    gearlines = gearlines.splitlines()
    commands = parse_commands(commandlines)
    gears = parse_gears(gearlines)

    gears_final = [x for x in gears if is_accepted(x, commands)]
    print("Solution 1 :", sum([sum(gear) for gear in gears_final]))

    print("Solution 2 :", find_range_valid_count(commands))
