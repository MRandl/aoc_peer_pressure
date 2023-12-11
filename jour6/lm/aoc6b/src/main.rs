use std::fs;

fn main() {
    let contents = fs::read_to_string("../input.txt")
        .expect("Should have been able to read the file");

    let lines : Vec<u64> = contents.split("\n")
                                   .filter(|l| !l.is_empty())
                                    .map(|l| l.chars()
                                                .filter(|c| c.is_numeric())
                                                .collect::<String>()
                                                .parse::<u64>()
                                                .unwrap()
                                    )
                                    .collect();
    let t = lines.get(0).expect("No times");
    let dist = lines.get(1).expect("No distances");

    let mut num_possible = 0;
    for j in 1..*t {
        if j*(t-j) > *dist {
            num_possible += 1;
        }
    }

    println!("Res : {num_possible}")
}
