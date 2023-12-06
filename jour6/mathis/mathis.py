from functools import reduce

def is_winning_run(wait_time, total_time, current_record):
    return (total_time - wait_time) * wait_time > current_record

with open("input.txt", "r") as f:
    lines = f.readlines()
    times = [int(word) for word in lines[0].split() if word.isdigit()]
    distances = [int(word) for word in lines[1].split() if word.isdigit()]

    #part 1
    summs = []
    for (time_of_run, record) in zip(times, distances):
        summ = 0
        for i in range(time_of_run):
            if is_winning_run(i, time_of_run, record):
                summ += 1
        summs.append(summ)
    print("solution 1 :", reduce(lambda x, y: x*y, summs))

    #part 2
    time = int(''.join([x for x in lines[0] if x.isdigit()]))
    dist = int(''.join([x for x in lines[1] if x.isdigit()]))
    summ = 0
    for i in range(time):
        if is_winning_run(i, time, dist):
            summ += 1
    print("solution 2 ;", summ)
