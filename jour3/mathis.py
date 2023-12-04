
#part 1
SIZE = 140

def neighbors(x, y, max_x = SIZE, max_y = SIZE): # generate all (i,j) pairs around a given point
    ret = []
    for i in [x - 1, x, x + 1]:
        for j in [y - 1, y, y + 1]:
            if (i != 0 or j != 0) and (i >= 0) and (j >= 0) and (i < max_x) and (j < max_y):
                ret.append((i, j))
    return ret

def adjacent(i, j, grid): # check that a number at pos (i,j) is neighbor to a part
    if not grid[i][j].isdigit():
        return False
    else:
        for (x_neigh, y_neigh) in neighbors(i, j):
            sym = grid[x_neigh][y_neigh]
            if sym != "." and not sym.isdigit():
                return True
        return False

def grid_filter(grid): # returns an array of True/False that marks interesting digits
    ret = []
    for i in range(len(grid)):
        ret.append([])
        for j in range(len(grid[0])):
            ret[i].append(adjacent(i, j, grid))
    return ret

def sum_of_good_numbers(grid):
    part_nearby = grid_filter(grid)
    sum = 0
    num_string = "" #current number we are looking at in the loop
    currently_neighbor = False # is there a part next to the number we're looking at ?

    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if grid[i][j].isdigit(): # if we are currently looking at a number,
                currently_neighbor = currently_neighbor or part_nearby[i][j] 
                num_string += grid[i][j]
            else:
                if len(num_string) > 0 and currently_neighbor: #otherwise, add the number we found and start again
                    sum += int(num_string)
                currently_neighbor = False
                num_string = ""
        if len(num_string) > 0 and currently_neighbor:
            sum += int(num_string)
            currently_neighbor = False
            num_string = ""
    return sum

with open("inputs/mathis.txt") as f:
    grid = f.readlines()
    sum = sum_of_good_numbers(grid)
        
print("solution 1 :", sum)

#part 2
def neighboring_stars(i, j, grid):
    ret = []
    for (x_neigh, y_neigh) in neighbors(i, j):
        if grid[x_neigh][y_neigh] == "*":
            ret.append((x_neigh, y_neigh))
    return ret

def sum_of_gear_products(grid): 
    stars = {} # mapping of star positions to all neighboring numbers
    
    num_string = "" # number we're currently processing
    curr_stars_found = set() #stars found around the number we're currently processing

    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if grid[i][j].isdigit(): # we are currently processing a number -> find stars around the number
                for star in neighboring_stars(i, j, grid):
                    curr_stars_found.add(star)
                num_string += grid[i][j]
            else: # we are done processing the number : record it as a neighbor of the star and continue
                for star in curr_stars_found:
                    stars[star] = stars.get(star, list()) + [int(num_string)]
                curr_stars_found = set()
                num_string = ""
        for star in curr_stars_found: # at the end of a line, consider the number is finished as well
            stars[star] = stars.get(star, list()) + [int(num_string)]
        curr_stars_found = set()
        num_string = ""
    
    gears = {k:v for (k,v) in stars.items() if len(v) == 2} # gears are stars with two neighbors
    
    sum = 0
    for (_, numbers) in gears.items(): 
        sum += numbers[0] * numbers[1]
    return sum


with open("inputs/mathis.txt") as f:
    grid = f.readlines()
    sum = sum_of_gear_products(grid)
        
print("solution 2 :", sum)