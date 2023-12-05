use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn main() {
    let test = String::from("eightwothree");
    let n = to_number(test);

    println!("{n}");

    if let Ok(lines) = read_lines("./input.txt") {
        let res : u32 = lines.filter_map(|l| l.ok())
                             .map(to_number)
                             .sum();
        println!("Result: {res}");
    }
}

// The output is wrapped in a Result to allow matching on errors
// Returns an Iterator to the Reader of the lines of the file.
fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}

fn to_number(mut s: String) -> u32 {
    s = s.replace("one",   "o1e")
         .replace("two",   "t2o")
         .replace("three", "t3e")
         .replace("four",  "f4r")
         .replace("five",  "f5e")
         .replace("six",   "s6x")
         .replace("seven", "s7n")
         .replace("eight", "e8t")
         .replace("nine",  "n9e");

    s.retain(|c| r#"0123456789"#.contains(c));

    let mut first = s.chars().nth(0).expect("expected a char").to_string();
    first.push_str(&s.chars().nth_back(0).expect("expected a char").to_string());

    first.parse::<u32>().unwrap()
}