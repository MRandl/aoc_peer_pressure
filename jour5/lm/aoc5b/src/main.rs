use std::fs;

fn main() {
    let contents = fs::read_to_string("../input.txt")
        .expect("Should have been able to read the file");

    let mut parts = contents.split("\n\n");

    let seeds_num = parts.next().expect("No seeds line?")
                                .split(" ")
                                .skip(1)
                                .map(|s| s.parse::<u64>().unwrap());
    let mut seeds : Vec<(u64, u64)>  = seeds_num.clone().step_by(2)
                                                .zip(seeds_num.skip(1).step_by(2))
                                                .map(|(a,b)| (a, a + b))
                                                .collect();

    let maps : Vec<Vec<((u64, u64),i128)>> = parts.map(|trans| parse_transitions(trans))
                                              .collect();

    for map in maps.iter() {
        let mut separators : Vec<u64> = map.iter()
                                       .flat_map(|((a,b), _c)| vec!(*a,*b)).collect();
        separators.dedup(); 
        
        seeds = seeds.iter()
                     .flat_map(|r| split_in_ranges(*r, separators.clone()))
                     .collect();
        
        for (seed_start, seed_end) in seeds.iter_mut() {
            'inner: for ((map_start, map_end), diff) in map.iter() {
                if in_interval(*seed_start, (*map_start, *map_end)){
                    *seed_start = (Into::<i128>::into(*seed_start) + *diff) as u64;
                    *seed_end = (Into::<i128>::into(*seed_end) + *diff) as u64;

                    break 'inner;
                }
            }
        }
    }
    let res : u64 = *seeds.iter().map(|(s,_e)| s).min().expect("There was no seeds?!?");

    println!("{res}")
}

fn in_interval(n : u64, (s,e): (u64, u64)) -> bool {
    n >= s && n < e
}

fn split_in_ranges((start, end): (u64, u64), separators : Vec<u64>) -> Vec<(u64, u64)>{
    let mut output_ranges : Vec<u64> = Vec::new();
    output_ranges.push(start);

    let mut sep_iter = separators.iter().skip_while(|s| **s <= start).peekable();
    while match sep_iter.peek(){Some(n) => **n < end, None => false } {
        output_ranges.push(*sep_iter.next().unwrap());
    }
    output_ranges.push(end);
    
    output_ranges.iter()
                 .zip(output_ranges.iter().skip(1))
                 .map(|(a, b)| (*a, *b))
                 .collect()
}

fn parse_transitions(t : &str) -> Vec<((u64, u64), i128)> {
    let trans = String::from(t);
    let mut to_sort : Vec<((u64, u64), i128)> = trans.split("\n")
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
         .collect::<Vec<_>>();
    to_sort.sort_by(|((start1, _end1), _diff1), ((start2, _end2), _diff2)| start1.cmp(start2));
    to_sort
}

//fn print_seeds(seeds: Vec<(u64, u64)>) {
//    for (a,b) in seeds.iter() {
//        println!("{a} {b}");
//    }
//}