use std::fs;

fn main() {
    let contents = fs::read_to_string("../input.txt")
        .expect("Should have been able to read the file");

    let lines : Vec<Vec<u32>> = contents.split("\n")
                                        .map(|l| l.split(" ")
                                            .filter(|s| !s.is_empty())
                                            .skip(1)
                                            .map(|s| s.parse::<u32>().unwrap())
                                            .collect()
                                        )
                                        .collect();
    let times = lines.get(0).expect("No times");
    let distances = lines.get(1).expect("No distances");

    let mut score : u32 = 1;
    for (i, t) in times.iter().enumerate(){
        let mut num_possible = 0;
        let dist = *distances.get(i).expect("Less distances than times.");
        for j in 1..*t {
            if j*(t-j) > dist {
                num_possible += 1;
            }
        }
        score *= num_possible;
    }

    println!("Res : {score}")
}
