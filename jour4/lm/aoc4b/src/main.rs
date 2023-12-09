use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::collections::HashSet;
use std::cmp::min;

fn main() {
    if let Ok(lines) = read_lines("../input.txt") {
        let scores : Vec<u16> = lines.filter_map(|l| l.ok())
                                         .map(|l| get_score(&l))
                                         .collect();

        let num_games = scores.len();
        let mut num_cards : Vec<u32> = vec![1; num_games];

        for i in 0..num_cards.len(){
            let n = num_cards[i];
            let end_ind : usize = min(*scores.get(i).expect("could not get") + (i as u16), num_games as u16) as usize;

            for j in (i+1)..=end_ind {
                num_cards[j] += n;
            }
        }
        
        let res : u32 = num_cards.iter().sum();
        
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

fn get_score(s: &str) -> u16 {
    let l = String::from(s);
    let v = l.split(":")
             .nth(1).expect("Some line has the wrong format :c")
             .split("|")
             .collect::<Vec<_>>();

    let w = to_set_of_uint(v.get(0).expect("No winning numbers :c"));
    let p = to_set_of_uint(v.get(1).expect("No playing numbers :c"));

    let intersection: HashSet<_> = w.intersection(&p).collect();
    intersection.len().try_into().unwrap()
}
