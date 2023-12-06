use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::cmp::max;

#[derive(Default)]
struct Hand {
    red:    u32,
    green:  u32,
    blue:   u32,
}

fn main() {
    if let Ok(lines) = read_lines("./input.txt") {
        let res : u32 = lines.filter_map(|l| l.ok())
                             .map(parse_game)
                             .map(|(_n, h)| h.red * h.green * h.blue)
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

fn find_num(l: &str) -> u32 {
    let mut num = String::from(l);
    num.retain(char::is_numeric);

    num.parse::<u32>().unwrap()
}

fn parse_game(l: String) -> (u32, Hand) {
    let mut split = l.split(":");
    let n = match split.next() {
        Some(s) => find_num(s),
        _ => 0
    };
    let h = match split.next(){
        Some(s) => parse_sack(s),
        _ => Hand::default(),
    };
    // println!("Game {n} hand {} {} {}", h.red, h.green, h.blue);
    (n, h)
}

fn parse_sack(s: &str) -> Hand {
    String::from(s)
     .split(";")
     .fold(Hand {red: 0, green: 0, blue: 0}, |acc, h| max_hands(acc, parse_hand(h)))
}

fn parse_hand(h: &str) -> Hand {
    let binding = String::from(h);
    let colors = binding.split(",");

    let mut hand: Hand = Hand::default();

    for c in colors{
        if c.contains("red"){
            hand.red = find_num(c);
        } else if c.contains("green") {
            hand.green = find_num(c);
        } else if c.contains("blue") {
            hand.blue = find_num(c);
        } else {
            panic!("What is that color ?!? {}", c);
        }
    }

    hand
}

fn max_hands(h1: Hand, h2: Hand) -> Hand {
    Hand {
        red: max(h1.red, h2.red),
        green: max(h1.green, h2.green),
        blue: max(h1.blue, h2.blue),
    }
}


