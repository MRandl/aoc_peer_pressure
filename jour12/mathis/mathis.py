from functools import cache

def analyze_char(c, line_next, nums, curr_group_size):
    if c == "#":
        return solve(line_next, nums, curr_group_size + 1)
    else:
        if curr_group_size != 0:
            if len(nums) > 0 and nums[0] == curr_group_size:
                return solve(line_next, nums[1:], 0)
            return 0
        else:
            return solve(line_next, nums, 0)

@cache # idea from reddit : use functools caching to speed up the computations
def solve(line, nums, curr_group_size):
    if len(line) == 0:
        if (len(nums) == 0 and curr_group_size == 0) or (len(nums) == 1 and curr_group_size == nums[0]):
            return 1 
        return 0
    
    if line[0] == "?":
        return analyze_char("#", line[1:], nums, curr_group_size) + analyze_char(".", line[1:], nums, curr_group_size)
    else:
        return analyze_char(line[0], line[1:], nums, curr_group_size)

with open("input.txt", "r") as f:
    lines = f.read().splitlines()
    lines = [x.split() for x in lines]
    x, y = [x[0] for x in lines], [x[1] for x in lines]
    y = [tuple([int(x) for x in nums.split(",")]) for nums in y]

    summ = 0
    for (line, nums) in zip(x, y):
        summ += solve(line, nums, 0)
    print("Solution 1 : ", summ)

    summ = 0
    for (line, nums) in zip(x, y):
        summ += solve("?".join([line] * 5), nums * 5, 0)
    print("Solution 2 : ", summ)
