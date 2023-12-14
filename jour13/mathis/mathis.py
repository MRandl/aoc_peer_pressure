def column(grid, index):
    return [grid[j][index] for j in range(len(grid))]

def row(grid, index):
    return grid[index]

def find_row_col(grid, check_rows, ignore = None):
    check = row if check_rows else column
    length = len(column(grid, 0) if check_rows else row(grid, 0))
    for attempt_sym in [x for x in range(1, length) if x != ignore]:
        amount_to_check = min(attempt_sym, length - attempt_sym)
        sym_ok = True
        for shift in range(amount_to_check):
            if(check(grid, attempt_sym - shift - 1) != check(grid, attempt_sym + shift)):
                sym_ok = False
        if sym_ok:
            return attempt_sym
    return None

def smudge(grid, x, y):
    ret = []
    to_insert = "." if grid[x][y] == "#" else "#"
    for i in range(len(grid)):
        if i != x:
            ret.append(grid[i])
        else:
            change_line = list(grid[i])
            change_line[y] = to_insert
            ret.append(''.join(change_line))
    return ret

def smudges(grid):
    all_smudges = []
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            all_smudges.append(smudge(grid, i, j))
    return all_smudges

with open("input.txt", "r") as f:
    lines = f.read().split("\n\n")
    lines = [l.strip().split("\n") for l in lines]
    
    result = 0
    for grid in lines:
        try_row = find_row_col(grid, True)
        if try_row is not None:
            result += try_row * 100
        else:
            result += find_row_col(grid, False)
    print("Solution 1 :", result)

    result = 0
    for grid in lines:
        try_row = find_row_col(grid, True)
        if try_row is not None:
            found_refl = ("row", try_row)
        else:
            found_refl = ("col", find_row_col(grid, False))
        
        for smudged in smudges(grid):
            try_row = find_row_col(smudged, True,  found_refl[1] if found_refl[0] == "row" else None)
            try_col = find_row_col(smudged, False, found_refl[1] if found_refl[0] == "col" else None)

            if try_row is not None:
                result += try_row * 100
                break
            elif try_col is not None:
                result += try_col
                break
    print("Solution 2 :", result)