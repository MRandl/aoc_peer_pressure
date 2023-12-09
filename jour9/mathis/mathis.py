def iterate_until_zeroes(numbers):
    results = [numbers]
    curr_numbers = numbers
    while not all([x == 0 for x in curr_numbers]):
        to_remove = curr_numbers[1:]
        curr_numbers = [x[0] - x[1] for x in zip(to_remove, curr_numbers)]
        results.append(curr_numbers)
    return results

def backwards_pass(line, append_right):
    numbers_iterated = iterate_until_zeroes(line)
    numbers_iterated[-1].append(0)
    for i in range(1, len(numbers_iterated)):
        curr_line = numbers_iterated[len(numbers_iterated) - i - 1]
        prev_line = numbers_iterated[len(numbers_iterated) - i]
        if append_right:
            curr_line.append(curr_line[-1] + prev_line[-1])
        else:
            curr_line.insert(0, curr_line[0] - prev_line[0])

    return numbers_iterated[0][-1 if append_right else 0]

with open("input.txt", "r") as f:
    lines = f.read().splitlines()
    lines = [list(map(int, x.split())) for x in lines]
    print("solution 1 :", sum([backwards_pass(x, True)  for x in lines]))
    print("solution 2 :", sum([backwards_pass(x, False) for x in lines]))
