use std::fs;
use std::fmt;
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

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
enum Side{
    In,
    Le,
    Ri,
    NV,
}

impl fmt::Display for Side {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
       match self {
            Side::In => write!(f, "."),
            Side::Le => write!(f, "O"),
            Side::Ri => write!(f, "I"),
            Side::NV => write!(f, " "),
       }
    }
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

        let mut sides : Vec<Vec<Side>> = vec![vec![Side::NV; max_x + 1]; max_y + 1];

        while out_dir != None && out_dir != Some(Dir::Success) {
            //mark the pipes around in the sides vector to see which tiles are inside/outide
            update_sides(&mut sides, curr, out_dir.unwrap(), map[curr.y][curr.x], max_x, max_y);

            match next_coord(curr, out_dir, max_x, max_y) {
                Some((coord, dir)) => {
                    curr = coord;
                    out_dir = pipe_output(map[curr.y][curr.x], dir);
                }
                None => {
                    out_dir = None;
                }
            }
        }

        if out_dir.is_some() {
            //Complete the sides table
            propagate_sides(&mut sides);

            //identify the inner side by checking which one is not on the inside
            let mut inner_side : Side = Side::NV;
            'fl: for s in sides[0].iter() {
                if *s == Side::Le {
                    inner_side = Side::Ri;
                    break 'fl;
                } else if *s == Side::Ri {
                    inner_side = Side::Le;
                    break 'fl;
                }
            }
            
            //count the elements on the inner side
            let mut count_inner = 0;
            for s in sides.iter().flat_map(|v| v.iter()) {
                if *s == inner_side { count_inner += 1;}
            }
            println!("The number of inside elements is {count_inner}");
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

fn update_sides(sides : &mut Vec<Vec<Side>>, curr : Coord, out_dir : Dir, pipe : Pipe, max_x : usize, max_y : usize){
    sides[curr.y][curr.x] = Side::In;
    let x : i32 = curr.x as i32;
    let y : i32 = curr.y as i32;
    match pipe {
        Pipe::NS => {
            match out_dir {
                Dir::N => {
                    change_tile(sides, x + 1, y, Side::Ri , max_x, max_y);
                    change_tile(sides, x - 1, y, Side::Le , max_x, max_y);
                },
                Dir::S => {
                    change_tile(sides, x + 1, y, Side::Le , max_x, max_y);
                    change_tile(sides, x - 1, y, Side::Ri , max_x, max_y);
                },
                _ => {},
            }
        },
        Pipe::EW => {
            match out_dir {
                Dir::E => {
                    change_tile(sides, x, y + 1, Side::Ri , max_x, max_y);
                    change_tile(sides, x, y - 1, Side::Le , max_x, max_y);
                },
                Dir::W => {
                    change_tile(sides, x, y + 1, Side::Le , max_x, max_y);
                    change_tile(sides, x, y - 1, Side::Ri , max_x, max_y);
                },
                _ => {},
            }
        },
        Pipe::NE => {
            match out_dir {
                Dir::N => {
                    change_tile(sides, x - 1, y, Side::Le , max_x, max_y);
                    change_tile(sides, x, y + 1, Side::Le , max_x, max_y);
                },
                Dir::E => {
                    change_tile(sides, x - 1, y, Side::Ri , max_x, max_y);
                    change_tile(sides, x, y + 1, Side::Ri , max_x, max_y);
                },
                _ => {},
            }
        },
        Pipe::NW => {
            match out_dir {
                Dir::N => {
                    change_tile(sides, x + 1, y, Side::Ri , max_x, max_y);
                    change_tile(sides, x, y + 1, Side::Ri , max_x, max_y);
                },
                Dir::W => {
                    change_tile(sides, x + 1, y, Side::Le , max_x, max_y);
                    change_tile(sides, x, y + 1, Side::Le , max_x, max_y);
                },
                _ => {},
            }
        }, 
        Pipe::SW => {
            match out_dir {
                Dir::S => {
                    change_tile(sides, x + 1, y, Side::Le , max_x, max_y);
                    change_tile(sides, x, y - 1, Side::Le , max_x, max_y);
                },
                Dir::W => {
                    change_tile(sides, x, y - 1, Side::Ri , max_x, max_y);
                    change_tile(sides, x + 1, y, Side::Ri , max_x, max_y);
                },
                _ => {},
            }
        }, 
        Pipe::SE => {
            match out_dir {
                Dir::S => {
                    change_tile(sides, x - 1, y, Side::Ri , max_x, max_y);
                    change_tile(sides, x, y - 1, Side::Ri , max_x, max_y);
                },
                Dir::E => {
                    change_tile(sides, x, y - 1, Side::Le , max_x, max_y);
                    change_tile(sides, x - 1, y, Side::Le , max_x, max_y);
                },
                _ => {},
            }
        },
        _ => {},
    }
}

fn change_tile(sides : &mut Vec<Vec<Side>>, x : i32, y : i32, val : Side, max_x : usize, max_y : usize){
    if x >= 0 && x <= max_x.try_into().unwrap() && y >= 0 && y <= max_y.try_into().unwrap() {
        let curr : Side = sides[y as usize][x as usize]; //Don't do dirty casting kids !
        match curr {
            Side::In => {},
            _ => { sides[y as usize][x as usize] = val; }
        }
    }
}

fn propagate_sides(sides : &mut Vec<Vec<Side>>){
    let mut count_iter : u32 = 0; //safeguard
    while count_iter < 1000 && sides.iter().any(|v| v.contains(&Side::NV)){
        count_iter += 1;
        let max_x : usize = sides[0].len() - 1; 
        let max_y : usize = sides.len() - 1;
        for x in 0..=max_x {
            for y in 0..=max_y {
                let val : Side = sides[y][x];

                let ix : i32 = x.try_into().unwrap();
                let iy : i32 = y.try_into().unwrap();

                if val == Side::Le || val == Side::Ri{
                    for i in (ix-1)..(ix+2){
                        for j in (iy-1)..(iy+2){
                            change_tile(sides, i, j, val, max_x, max_y);
                        }
                    }
                }
            }
        }
    }
}
