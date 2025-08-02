import Foundation

enum MajorArcana: String, CaseIterable {
    case fool = "fool"
    case magician = "magician"
    case highPriestess = "high_priestess"
    case empress = "empress"
    case emperor = "emperor"
    case hierophant = "hierophant"
    case lovers = "lovers"
    case chariot = "chariot"
    case strength = "strength"
    case hermit = "hermit"
    case wheelOfFortune = "wheel_of_fortune"
    case justice = "justice"
    case hangedMan = "hanged_man"
    case death = "death"
    case temperance = "temperance"
    case devil = "devil"
    case tower = "tower"
    case star = "star"
    case moon = "moon"
    case sun = "sun"
    case judgement = "judgement"
    case world = "world"
    
    var localizedName: String {
        switch self {
        case .fool: return "愚人"
        case .magician: return "魔术师"
        case .highPriestess: return "女祭司"
        case .empress: return "女皇"
        case .emperor: return "皇帝"
        case .hierophant: return "教皇"
        case .lovers: return "恋人"
        case .chariot: return "战车"
        case .strength: return "力量"
        case .hermit: return "隐士"
        case .wheelOfFortune: return "命运之轮"
        case .justice: return "正义"
        case .hangedMan: return "倒吊人"
        case .death: return "死神"
        case .temperance: return "节制"
        case .devil: return "恶魔"
        case .tower: return "高塔"
        case .star: return "星星"
        case .moon: return "月亮"
        case .sun: return "太阳"
        case .judgement: return "审判"
        case .world: return "世界"
        }
    }
    
    var imageName: String {
        switch self {
        case .fool: return "tarot_card_1"
        case .magician: return "tarot_card_2"
        case .highPriestess: return "tarot_card_3"
        case .empress: return "tarot_card_4"
        case .emperor: return "tarot_card_5"
        case .hierophant: return "tarot_card_6"
        case .lovers: return "tarot_card_7"
        case .chariot: return "tarot_card_8"
        case .strength: return "tarot_card_9"
        case .hermit: return "tarot_card_10"
        case .wheelOfFortune: return "tarot_card_11"
        case .justice: return "tarot_card_12"
        case .hangedMan: return "tarot_card_13"
        case .death: return "tarot_card_14"
        case .temperance: return "tarot_card_15"
        case .devil: return "tarot_card_16"
        case .tower: return "tarot_card_17"
        case .star: return "tarot_card_18"
        case .moon: return "tarot_card_19"
        case .sun: return "tarot_card_20"
        case .judgement: return "tarot_card_21"
        case .world: return "tarot_card_22"
        }
    }
}

enum MinorArcanaRank: String, CaseIterable {
    case ace = "ace"
    case two = "two"
    case three = "three"
    case four = "four"
    case five = "five"
    case six = "six"
    case seven = "seven"
    case eight = "eight"
    case nine = "nine"
    case ten = "ten"
    case page = "page"
    case knight = "knight"
    case queen = "queen"
    case king = "king"
    
    var localizedName: String {
        switch self {
        case .ace: return "A"
        case .two: return "二"
        case .three: return "三"
        case .four: return "四"
        case .five: return "五"
        case .six: return "六"
        case .seven: return "七"
        case .eight: return "八"
        case .nine: return "九"
        case .ten: return "十"
        case .page: return "侍从"
        case .knight: return "骑士"
        case .queen: return "王后"
        case .king: return "国王"
        }
    }
}

enum MinorArcanaSuit: String, CaseIterable {
    case wands = "wands"
    case cups = "cups"
    case swords = "swords"
    case pentacles = "pentacles"
    
    var localizedName: String {
        switch self {
        case .wands: return "权杖"
        case .cups: return "圣杯"
        case .swords: return "宝剑"
        case .pentacles: return "星币"
        }
    }
    
    var color: String {
        switch self {
        case .wands: return "red"
        case .cups: return "blue"
        case .swords: return "gray"
        case .pentacles: return "green"
        }
    }
}

enum TarotCardType: Identifiable, CaseIterable {
    case majorArcana(MajorArcana)
    case minorArcana(suit: MinorArcanaSuit, rank: MinorArcanaRank)
    
    var id: String {
        switch self {
        case .majorArcana(let card):
            return card.rawValue
        case .minorArcana(let suit, let rank):
            return "\(rank.rawValue)_of_\(suit.rawValue)"
        }
    }
    
    var rawValue: String {
        id
    }
    
    var localizedName: String {
        switch self {
        case .majorArcana(let card):
            return card.localizedName
        case .minorArcana(let suit, let rank):
            return "\(suit.localizedName)\(rank.localizedName)"
        }
    }
    
    var category: TarotCategory {
        switch self {
        case .majorArcana:
            return .majorArcana
        case .minorArcana(let suit, _):
            switch suit {
            case .wands: return .wands
            case .cups: return .cups
            case .swords: return .swords
            case .pentacles: return .pentacles
            }
        }
    }
    
    static var allCases: [TarotCardType] {
        var cases: [TarotCardType] = []
        
        for majorCard in MajorArcana.allCases {
            cases.append(.majorArcana(majorCard))
        }
        
        for suit in MinorArcanaSuit.allCases {
            for rank in MinorArcanaRank.allCases {
                cases.append(.minorArcana(suit: suit, rank: rank))
            }
        }
        
        return cases
    }
    
    static let fool = TarotCardType.majorArcana(.fool)
    static let aceOfWands = TarotCardType.minorArcana(suit: .wands, rank: .ace)
    static let aceOfCups = TarotCardType.minorArcana(suit: .cups, rank: .ace)
    static let aceOfSwords = TarotCardType.minorArcana(suit: .swords, rank: .ace)
    static let aceOfPentacles = TarotCardType.minorArcana(suit: .pentacles, rank: .ace)
}

enum TarotCategory: String, CaseIterable {
    case majorArcana = "major_arcana"
    case wands = "wands"
    case cups = "cups"
    case swords = "swords"
    case pentacles = "pentacles"
    
    var localizedName: String {
        switch self {
        case .majorArcana: return "大阿尔卡那"
        case .wands: return "权杖"
        case .cups: return "圣杯"
        case .swords: return "宝剑"
        case .pentacles: return "星币"
        }
    }
}

struct TarotCardModel: TarotCard {
    let id = UUID()
    let cardType: TarotCardType
    var isRevealed: Bool
    
    var name: String {
        cardType.localizedName
    }
    
    /// 卡牌显示名称（别名）
    var displayName: String {
        name
    }
    
    var imageName: String {
        switch cardType {
        case .majorArcana(let majorCard):
            return majorCard.imageName
        case .minorArcana(let suit, let rank):
            return "\(rank.rawValue)_of_\(suit.rawValue)"
        }
    }
    
    init(cardType: TarotCardType, isRevealed: Bool = false) {
        self.cardType = cardType
        self.isRevealed = isRevealed
    }
    
    init(majorArcana: MajorArcana, isRevealed: Bool = false) {
        self.init(cardType: .majorArcana(majorArcana), isRevealed: isRevealed)
    }
    
    init(suit: MinorArcanaSuit, rank: MinorArcanaRank, isRevealed: Bool = false) {
        self.init(cardType: .minorArcana(suit: suit, rank: rank), isRevealed: isRevealed)
    }
}

struct Card: TarotCard {
    let id = UUID()
    let name: String
    let imageName: String
    var isRevealed: Bool
    
    init(name: String, imageName: String, isRevealed: Bool = false) {
        self.name = name
        self.imageName = imageName
        self.isRevealed = isRevealed
    }
}

struct Position: TarotPosition {
    let id = UUID()
    let name: String
    let index: Int
}