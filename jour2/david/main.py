#!/usr/bin/env python

import sys

COLORS = {
    'red': 12,
    'green': 13,
    'blue': 14,
}

def handle_file(fname):
    with open(fname, "r") as f:
        res = 0

        for line in f:
            line = line.strip()
            if not line:
                break

            [game, draws] = line.split(':')
            game_id = game.split(' ')[1]

            maxs = {
                'red': 0,
                'green': 0,
                'blue': 0,
            }
            for draw in draws.split(';'):
                for part in draw.split(', '):
                    [n, c] = part.strip().split(' ')
                    maxs[c] = max(maxs[c], int(n))

            good = True
            for c, s in maxs.items():
                if COLORS[c] < s:
                    good = False

            if good:
                res += int(game_id)

        return res

if __name__ == '__main__':
    for fname in sys.argv[1:]:
        print(f'{fname}: {handle_file(fname)}')
