
#part 1
sum = 0
with open("inputs/mathis.txt") as f:
    for l in f.readlines():
        nums = [x for x in l if x.isdigit()]
        sum += int(nums[0] + nums[-1]) # '+' is concat here
print("solution 1 :", sum)

#part 2
str2num = {"zero" : "0", "one" : "1", "two" : "2", "three" : "3", "four" : "4", "five" : "5", \
    "six" : "6", "seven" : "7", "eight" : "8", "nine" : "9"} 

def analyze_head(s):
    for strnum in str2num.keys():
        if s.startswith(strnum):
            return str2num[strnum]
    if s[0].isdigit():
        return s[0]
    return analyze_head(s[1:]) 

def analyze_tail(s):
    for strnum in str2num.keys():
        if s.endswith(strnum):
            return str2num[strnum]
    if s[-1].isdigit():
        return s[-1]
    return analyze_tail(s[:-1]) 

sum = 0
with open("inputs/mathis.txt") as f:
    for l in f.readlines():
        sum += int(analyze_head(l) + analyze_tail(l)) # '+' is concat here
print("solution 2 :", sum)
