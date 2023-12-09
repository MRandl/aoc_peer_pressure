use std::fs;

fn main() {
    let contents = fs::read_to_string("../input.txt")
        .expect("Should have been able to read the file");

    let mut parts = contents.split("\n\n");

    let mut seeds : Vec<u64> = parts.next().expect("No seeds line?")
                                .split(" ")
                                .skip(1)
                                .map(|s| s.parse::<u64>().unwrap())
                                .collect();
    
    let maps : Vec<Vec<((u64, u64),i128)>>= parts.map(|trans| trans.split("\n")
                                                            .filter(|l| !l.is_empty())
                                                            .skip(1)
                                                            .map(|l| {
                                                                let nums : Vec<u64> = l.split(" ")
                                                                                       .filter(|s| !s.is_empty())
                                                                                       .map(|s| s.parse::<u64>().expect("parsing error"))
                                                                                       .collect();
                                                                
                                                                let start : u64 = nums[1];
                                                                let end   : u64 = start + nums[2];
                                                                let diff  : i128 = Into::<i128>::into(nums[0]) - Into::<i128>::into(start);
                                                                
                                                                ((start, end), diff)
                                                                })
                                                            .collect()
                                                )
                                              .collect();

    for map in maps.iter() {
        for seed in seeds.iter_mut() {
            'inner: for ((start, end), diff) in map.iter() {
                if in_interval(*seed, (*start, *end)){
                    *seed = (Into::<i128>::into(*seed) + *diff) as u64;
                    break 'inner;
                }
            }
        }
    }
    let res : u64 = *seeds.iter().min().expect("There was no seeds?!?");

    println!("{res}")
}

fn in_interval(n : u64, (s,e): (u64, u64)) -> bool {
    n >= s && n < e
}