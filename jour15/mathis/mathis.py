def hash_string(h):
    summ = 0
    for char in h:
        summ = (summ + ord(char)) * 17 % 256
    return summ

def run_instruction(i, boxes):
    if "=" in i:
        label, focal = i.split("=")
        box = boxes[hash_string(label)]
        if(label in box):
            box[label] = (int(focal), box[label][1])
        else:
            box[label] = (int(focal), len(box) + 1)
    else:
        label = i[:-1]
        box = boxes[hash_string(label)]
        if label in box:
            _, index = box[label]
            newbox = {k:(focal, pos if pos < index else pos - 1) for k, (focal, pos) in box.items()}
            del newbox[label]
            boxes[hash_string(label)] = newbox

def compute_score(boxes):
    summ = 0
    for box_ind, box in enumerate(boxes):
        for (hashh, (focal, lens_ind)) in box.items():
            summ += (1 + box_ind) * lens_ind * focal
    return summ

with open("input.txt", "r") as f:
    lines = f.read().split(",")
    print("Solution 1 :", sum([hash_string(h) for h in lines]))

    boxes = [{} for _ in range(256)]
    for inst in lines:
        run_instruction(inst, boxes)
    print("Solution 2 :", compute_score(boxes))
