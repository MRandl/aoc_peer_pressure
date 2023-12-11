use std::fs;
use std::cmp::Ordering;
use std::collections::HashMap;

#[derive(Hash, PartialOrd, Ord, PartialEq, Eq, Clone, Copy, Debug)]
enum Suit{
    A,
    K,
    Q,
    J,
    T, 
    Nine,
    Eight,
    Seven,
    Six,
    Five,
    Four,
    Three,
    Two,
    One
}



impl From<char> for Suit {
    fn from(c : char) -> Self {
        match c {
            'A' => Suit::A,
            'K' => Suit::K,
            'Q' => Suit::Q,
            'J' => Suit::J,
            'T' => Suit::T,
            '9' => Suit::Nine,
            '8' => Suit::Eight,
            '7' => Suit::Seven,
            '6' => Suit::Six,
            '5' => Suit::Five,
            '4' => Suit::Four,
            '3' => Suit::Three,
            '2' => Suit::Two,
            '1' => Suit::One,
            _ => panic!("Not a valid card suit !")
        }
    }
}

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
struct Hand(Suit, Suit, Suit, Suit, Suit);

impl From<&str> for Hand {
    fn from(string : &str) -> Self {
        let s = String::from(string);
        let mut chars = s.chars();
        let mut hand  = Hand(Suit::One, Suit::One, Suit::One, Suit::One, Suit::One);

        hand.0 = Suit::from(chars.next().unwrap());
        hand.1 = Suit::from(chars.next().unwrap());
        hand.2 = Suit::from(chars.next().unwrap());
        hand.3 = Suit::from(chars.next().unwrap());
        hand.4 = Suit::from(chars.next().unwrap());
        
        hand
    }
}

fn hand_to_count(hand: Hand) -> Vec<u32>{
    let mut map : HashMap<Suit, u32> = HashMap::new();

    for c in hand_to_array(hand).iter(){
        map.entry(*c).and_modify(|counter| *counter += 1).or_insert(1);
    }

    let mut vec: Vec<u32> = map.into_values().collect();
    vec.sort_by(|a, b| a.cmp(b).reverse());
    vec
}

fn hand_to_tuple(h: Hand) -> (Suit, Suit, Suit, Suit, Suit){
    (h.0, h.1, h.2, h.3, h.4)
}

fn hand_to_array(h: Hand) -> [Suit; 5]{
    [h.0, h.1, h.2, h.3, h.4]
}

//fn tuple_to_hand(h: (Suit, Suit, Suit, Suit, Suit)) -> Hand{
//    Hand(h.0, h.1, h.2, h.3, h.4)
//}

impl Ord for Hand {
    fn cmp(&self, other: &Self) -> Ordering {
        hand_to_count(*self).cmp(&hand_to_count(*other)).reverse().then(hand_to_tuple(*self).cmp(&hand_to_tuple(*other)))
    }
}

impl PartialOrd for Hand {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering>{
        Some(self.cmp(other))
    }
}

fn main() {
    let contents = fs::read_to_string("../input.txt")
        .expect("Should have been able to read the file");
    
    let mut hands_and_bet : Vec<(Hand, u32)> = contents.split("\n")
                                                .filter(|l| !l.is_empty())
                                                .map(|l| {
                                                        let mut parts = l.split(" ");
                                                        let hand = Hand::from(parts.next().expect("Missing hand"));
                                                        let bet = parts.next()
                                                                    .expect("missing bet")
                                                                    .parse::<u32>()
                                                                    .expect("Bet not a number");
                                                        (hand, bet)
                                                    }
                                                )
                                                .collect();
    
    hands_and_bet.sort_by(|(h0, _b0), (h1, _b1)| h0.cmp(h1));
    
    let mut score : u32 = 0;
    let max_points : u32 = hands_and_bet.len().try_into().unwrap();

    for (i, (_h,b)) in hands_and_bet.iter().enumerate() {
        let bet : u32 = *b;
        let hand_points : u32 = max_points - <usize as TryInto<u32>>::try_into(i).unwrap();
        let hand_score : u32 = bet * hand_points;
        score += hand_score;
    }

    println!("Result : {score}");
}
