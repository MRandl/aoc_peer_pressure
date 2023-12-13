use std::fs;

fn main() {
    let contents = fs::read_to_string("../input.txt")
        .expect("Should have been able to read the file");
    
    let suites : Vec<Vec<i32>>= contents.split("\n")
                                        .map(|l| l.split(" ")
                                                    .map(|v| v.parse::<i32>()
                                                            .expect("Not a number"))
                                                    .collect()
                                        )
                                        .collect();

    let res : i32 = suites.iter().fold(0, |acc, v| acc + predict_previous(v));

    println!("Result : {res}");
}

fn predict_previous(v : &Vec<i32>) -> i32 {
    let mut seqs : Vec<Vec<i32>> = Vec::new();
    seqs.push(v.clone());

    //go downwards
    while !seqs.last().unwrap().iter().all(|&n| n == 0) {
        let prev_seq : Vec<i32> = seqs.last().expect("No previous sequence !").to_vec();
        let new_seq  : Vec<i32> = prev_seq.clone()
                                            .iter()
                                            .zip(prev_seq.clone().iter().skip(1))
                                            .map(|(a, b)| b - a)
                                            .collect();

        seqs.push(new_seq);
    }

    for i in (1..seqs.len()).rev() {
        let below : i32 = *seqs[i].first().expect("Empty lower vec");
        let right  : i32 = *seqs[i - 1].first().expect("Empty lower vec");
        seqs[i-1].insert(0, right - below);
    }

    *seqs.first().unwrap().first().unwrap()
}
