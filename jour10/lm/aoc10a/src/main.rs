use std::fs;
use core::slice::Iter;

#[derive(Clone, Copy, Debug)]
enum Pipe{
    NS,
    EW,
    NE,
    NW, 
    SW, 
    SE,
    Gr,
    St,
}

impl From<char> for Pipe {
    fn from(c : char) -> Self {
        match c {
            '|' => Pipe::NS,
            '-' => Pipe::EW,
            'L' => Pipe::NE,
            'J' => Pipe::NW,
            '7' => Pipe::SW,
            'F' => Pipe::SE,
            '.' => Pipe::Gr,
            'S' => Pipe::St,
            _ => panic!("Not a valid ground !")
        }
    }
}

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
enum Dir{
    N,
    S,
    E,
    W,
    Success,
}

impl Dir {
    pub fn iter() -> Iter<'static, Dir> {
        static DIRECTIONS: [Dir; 4] = [Dir::N, Dir::S, Dir::E, Dir::W];
        DIRECTIONS.iter()
    }
}

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
struct Coord{
    x : usize,
    y : usize,
}

fn main() {
    let contents = fs::read_to_string("../input.txt")
        .expect("Should have been able to read the file");

    let (map, start) : (Vec<Vec<Pipe>>, Coord) = load_map_and_start(&contents);

    println!("Starting coordinates: x = {}, y = {}", start.x, start.y);
    //top left is coordinate (0,0)
    let max_x : usize = map[0].len() - 1;
    let max_y : usize = map.len() - 1;

    'out : for start_direction in Dir::iter() {
        let mut curr : Coord = start.clone();
        let mut out_dir : Option<Dir> = Some(start_direction.clone());
        let mut count : u32 = 0;

        while out_dir != None && out_dir != Some(Dir::Success) {
            match next_coord(curr, out_dir, max_x, max_y) {
                Some((coord, dir)) => {
                    curr = coord;
                    out_dir = pipe_output(map[curr.y][curr.x], dir);
                }
                None => {
                    out_dir = None;
                }
            }
            count += 1;
        }
        if out_dir.is_some() {
            println!("The length of the loop is {count}, furthest point is at {}", count/2);
            break 'out;
        }
    }
}

fn load_map_and_start(contents: &String) -> (Vec<Vec<Pipe>>, Coord) {
    let mut map : Vec<Vec<Pipe>>= Vec::new();
    let mut start : Coord = Coord {x : 0, y : 0};

    //Load map
    for (i,l) in contents.split("\n").enumerate() {
        let mapline : Vec<Pipe> = 
            l.chars()
                .enumerate()
                .map(|(j, c)| {
                    //Also memorize the starting point upon visiting it
                    if c == 'S' { start.x = j; start.y = i;}
                    Pipe::from(c)
                })
                .collect();
        map.push(mapline);
    }

    (map, start)
}

//output the direction in which it will come out
fn pipe_output(p: Pipe, in_dir : Dir) -> Option<Dir> {
    match p {
        Pipe::NS => match in_dir {
            Dir::N => Some(Dir::S),
            Dir::S => Some(Dir::N),
            _ => None,
        },
        Pipe::EW => match in_dir {
            Dir::E => Some(Dir::W),
            Dir::W => Some(Dir::E),
            _ => None,
        },
        Pipe::NE => match in_dir {
            Dir::N => Some(Dir::E),
            Dir::E => Some(Dir::N),
            _ => None,
        },
        Pipe::NW => match in_dir {
            Dir::N => Some(Dir::W),
            Dir::W => Some(Dir::N),
            _ => None,
        },
        Pipe::SW => match in_dir {
            Dir::S => Some(Dir::W),
            Dir::W => Some(Dir::S),
            _ => None,
        },
        Pipe::SE => match in_dir {
            Dir::S => Some(Dir::E),
            Dir::E => Some(Dir::S),
            _ => None,
        },
        Pipe::St => Some(Dir::Success),
        _ => None,
    }
}

//check if going that way is possible, compute next coordinate and direction from which the next 
//tile is entered
fn next_coord(curr : Coord, out_dir : Option<Dir>, max_x : usize, max_y : usize) -> Option<(Coord, Dir)> {
    match out_dir {        
        Some(Dir::N) => {
            if curr.y > 0 {
                Some((Coord{x: curr.x, y: curr.y - 1}, Dir::S))
            } else {
                None
            }
        },
        Some(Dir::S) => {
            if curr.y < max_y {
                Some((Coord{x: curr.x, y: curr.y + 1}, Dir::N))
            } else {
                None
            }
        },
        Some(Dir::E) => {
            if curr.x < max_x {
                Some((Coord{x: curr.x + 1, y: curr.y}, Dir::W))
            } else {
                None
            }
        },
        Some(Dir::W) => {
            if curr.x > 0 {
                Some((Coord{x: curr.x - 1, y: curr.y}, Dir::E))
            } else {
                None
            }
        },
        _ => None,
    }
}


