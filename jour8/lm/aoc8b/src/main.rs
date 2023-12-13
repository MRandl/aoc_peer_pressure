use std::{
    fs,
    collections::HashMap,
};
use num::integer::lcm;

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

    let mut pos : Vec<String> = maps.clone()
                                  .into_keys()
                                  .filter(|k| k.as_bytes()[2] == b'A')
                                  .collect();

    let mut pos_num : Vec<usize> = vec![0; pos.len()];

    for (j, p) in pos.iter_mut().enumerate(){
        let mut i : usize = 0;
        let num_moves = moves.len();

        while p.as_bytes()[2] != b'Z' {
            *p = match maps.get(p) {
                Some((l, r)) => match moves[i % num_moves] {
                                    b'L' => l.clone(),
                                    b'R' => r.clone(),
                                    _ => panic!("Invalid move character")
                                }
                _ => panic!("This location doesn't exist")
            };
            i += 1;
        }
        pos_num[j] = i;
    }

    let res = pos_num.iter().fold(1, |acc, x| lcm(acc, *x));

    println!("Result: {res}");
    //LONG LOOP BRUTEFORCE SOLUTION, YOU NEED TO KNOW THAT PATHS LOOPS TO SOLVE IT
    //let mut i : usize = 0;
    //let num_moves = moves.len();
//
    //while !pos.iter().all(|s| s.as_bytes()[2] == b'Z') {
    //    let m = moves[i % num_moves];
//
    //    for p in pos.iter_mut(){
    //        p = match maps.get(p) {
    //            Some((l, r)) => match m {
    //                                b'L' => l.clone(),
    //                                b'R' => r.clone(),
    //                                _ => panic!("Invalid move character")
    //                            }
    //            _ => panic!("This location doesn't exist")
    //        };
    //        println!("{p}");
    //    }
    //    println!(" ");
    //    i += 1;
    //}
}
