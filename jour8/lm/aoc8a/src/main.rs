use std::{
    fs,
    collections::HashMap,
};

fn main() {
    let contents = fs::read_to_string("../input.txt")
        .expect("Should have been able to read the file");
    
    let mut moves_and_maps = contents.split("\n\n");

    let moves_string = String::from(moves_and_maps.next().unwrap());
    let moves = moves_string.as_bytes();

    let maps : HashMap<String, (String, String)> = 
        moves_and_maps.next()
                      .unwrap()
                      .split("\n")
                      .map(|s| (String::from(&s[0..3]), (String::from(&s[7..10]), String::from(&s[12..15]))))
                      .collect();

    let mut pos : &str = "AAA";
    let mut i : usize = 0;
    let num_moves = moves.len();

    while pos != "ZZZ" {
        pos = match maps.get(pos) {
            Some((l, r)) => match moves[i % num_moves] {
                                b'L' => &l,
                                b'R' => &r,
                                _ => panic!("Invalid move character")
                            }
            _ => panic!("This location doesn't exist")
        };
        i += 1;
    }
    println!("Result : {i}");
}
