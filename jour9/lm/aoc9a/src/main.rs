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

    let res : i32 = suites.iter().fold(0, |acc, v| acc + predict_next(v));

    println!("Result : {res}");
}

fn predict_next(v : &Vec<i32>) -> i32 {
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
        let below : i32 = *seqs[i].last().expect("Empty lower vec");
        let left  : i32 = *seqs[i - 1].last().expect("Empty lower vec");
        seqs[i-1].push(below + left);
    }

    *seqs.first().unwrap().last().unwrap()
}
