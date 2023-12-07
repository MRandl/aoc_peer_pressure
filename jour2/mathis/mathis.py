#part 1

# turns "Game 1: 9 red, 2 green, 13 blue; 10 blue, 2 green, 13 red; 8 blue, 3 red, 6 green; 5 green, 2 red, 1 blue"
# into 
# {id : 1, runs : [(9, 2, 13), (13, 2, 10), ...]}. tuples are sorted by rgb. missing are filled with 0.
def parse_line(line):
    split = line.split(":")

    head, line = split[0], split[1] # head has game id, line is rest
    game_id = int(head[5:])

    runs_parsed = [] # each line has several runs, each run has several colors
    for run in line.split(";"): 
        split_run = run.split(",")
        red = [x for x in split_run if "red" in x]
        red = 0 if len(red) == 0 else red[0].split(" ")[1]
        green = [x for x in split_run if "green" in x]
        green = 0 if len(green) == 0 else green[0].split(" ")[1]
        blue =  [x for x in split_run if "blue" in x]
        blue = 0 if len(blue) == 0 else blue[0].split(" ")[1]
        runs_parsed.append((int(red), int(green), int(blue)))
    
    return {"id" : game_id, "runs" : runs_parsed}

def is_valid_run(parsed_line):
    for (r, g, b) in parsed_line["runs"]:
        if r > 12 or g > 13 or b > 14:
            return False
    return True

sum = 0
with open("input.txt") as f:
    for l in f.readlines():
        parsed = parse_line(l)
        if(is_valid_run(parsed)):
            sum += parsed["id"]
        
print("solution 1 :", sum)

def power_of_parsed(parsed_line):
    max_r = max([x[0] for x in parsed_line["runs"]])
    max_g = max([x[1] for x in parsed_line["runs"]])
    max_b = max([x[2] for x in parsed_line["runs"]])

    return max_r * max_g * max_b

sum = 0
with open("input.txt") as f:
    for l in f.readlines():
        parsed = parse_line(l)
        sum += power_of_parsed(parsed)

print("solution 2 :", sum)
