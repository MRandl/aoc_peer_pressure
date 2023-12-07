use std::{
    fs::File,
    io::{prelude::*, BufReader},
    path::Path,
    collections::HashMap,
};

fn main() {
    let lines = lines_from_file("../input.txt");
    let mut gears: HashMap<(usize, usize), (u8, u32)> = HashMap::new();

    for (ln, line) in lines.clone().into_iter().enumerate() {
        let mut in_num = false;
        let mut num_value = 0;
        let mut num_start = 0;

        for (i, c) in line.chars().enumerate(){
            if c.is_numeric() {
                // update in/out of number status
                if !in_num {
                    in_num = true;
                    num_start = i;
                }
                // update number value
                num_value *= 10;
                num_value += c.to_digit(10).expect("Not a number !");
            }

            if in_num && (i == (line.len() - 1) || in_num && !c.is_numeric()){
                //determine bounds to check
                let left_bound  = if num_start != 0 { num_start - 1 } else { num_start };
                let right_bound = i;
                let top_bound   = if ln != 0 {ln - 1} else {ln};
                let bot_bound   = if ln != lines.len() - 1 {ln + 1} else {ln};

                //look for symbols around the number
                for k in top_bound..=bot_bound{
                    for j in left_bound..=right_bound{
                        let p = lines[k].chars().nth(j).expect("Index {j} out of bounds !");
                        //if touches a gear, check if that gear is known
                        if p == '*' {
                            gears.insert( (k,j), 
                                match gears.get(&(k,j)) {
                                    Some((1, x)) => (2, x * num_value),
                                    None => (1, num_value),
                                    _ => (0, 0),
                                }
                            );
                        }
                    }
                }
                //set out of number
                in_num = false;
                num_value = 0;
            }
        }
    }

    //for v in gears.values() {
    //    if v.0 == 2 {println!("hello !")};
    //}
    
    let sum: u32 = gears.values()
                        .filter(|v| v.0 == 2)
                        .map(|(_n, v)| v)
                        .sum();

    println!("Result : {sum}");
}

fn lines_from_file(filename: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(filename).expect("no such file");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.expect("Could not parse line"))
        .collect()
}
