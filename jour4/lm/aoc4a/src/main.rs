use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::collections::HashSet;

fn main() {
    if let Ok(lines) = read_lines("../input.txt") {
        let res : u32 = lines.filter_map(|l| l.ok())
                             .map(|l| get_score(&l))
                             .sum();
        
    println!("Result: {res}");
    }
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
let file = File::open(filename)?;
Ok(io::BufReader::new(file).lines())
}

fn to_set_of_uint(s: &str) -> HashSet<u32> {
String::from(s).split(" ")
               .filter(|s| !s.is_empty())
               .map(|s| s.parse::<u32>().unwrap())
               .collect()
}

fn get_score(s: &str) -> u32 {
    let l = String::from(s);
    let v = l.split(":")
             .nth(1).expect("Some line has the wrong format :c")
             .split("|")
             .collect::<Vec<_>>();

    let w = to_set_of_uint(v.get(0).expect("No winning numbers :c"));
    let p = to_set_of_uint(v.get(1).expect("No playing numbers :c"));

    let intersection: HashSet<_> = w.intersection(&p).collect();
    if intersection.is_empty(){
        0
    } else {
        let base: u32 = 2;
        base.pow((intersection.len() - 1).try_into().unwrap())
    }
}
