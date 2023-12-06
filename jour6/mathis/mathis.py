from functools import reduce
import math

def is_winning_run(wait_time, total_time, current_record):
    return (total_time - wait_time) * wait_time > current_record

def solve_analytical(total_time, current_record):
    delta = (total_time ** 2) - (4 * current_record)
    root1 = math.ceil((total_time - math.sqrt(delta)) / 2)
    root2 = math.floor((total_time + math.sqrt(delta)) / 2)
    return int(root2 - root1 + 1)

with open("input.txt", "r") as f:
    lines = f.readlines()
    times = [int(word) for word in lines[0].split() if word.isdigit()]
    distances = [int(word) for word in lines[1].split() if word.isdigit()]

    #part 1
    summs = []
    for (time_of_run, record) in zip(times, distances):
        summs.append(solve_analytical(time_of_run, record))
    print("solution 1 :", reduce(lambda x, y: x*y, summs))

    #part 2
    time = int(''.join([x for x in lines[0] if x.isdigit()]))
    dist = int(''.join([x for x in lines[1] if x.isdigit()]))
    print("solution 2 ", solve_analytical(time, dist))

