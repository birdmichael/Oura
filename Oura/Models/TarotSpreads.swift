import Foundation

struct UniversalTarotSpread: TarotSpread {
    let id = UUID()
    let title: String
    let subtitle: String
    let instruction: String
    let additionalInfo: String 
    let positions: [TarotPosition]
    var cards: [any TarotCard]
    let spreadType: TarotSpreadType
    
    init(spreadType: TarotSpreadType) {
        self.spreadType = spreadType
        self.title = spreadType.localizedTitle
        self.subtitle = spreadType.subtitle
        self.instruction = spreadType.instruction
        self.additionalInfo = spreadType.additionalInfo
        
        self.positions = spreadType.positions.enumerated().map { index, name in
            Position(name: name, index: index)
        }
        
        self.cards = []
    }
}

enum TarotCardName: String, CaseIterable {
    case fool = "愚者"
    case magician = "魔术师"
    case highPriestess = "女教皇"
    case empress = "皇后"
    case emperor = "皇帝"
    case hierophant = "教皇"
    case lovers = "恋人"
    case chariot = "战车"
    case strength = "力量"
    case hermit = "隐者"
    case wheelOfFortune = "命运之轮"
    case justice = "正义"
    case hangedMan = "倒吊人"
    case death = "死神"
    case temperance = "节制"
    case devil = "恶魔"
    case tower = "塔"
    case star = "星星"
    case moon = "月亮"
    case sun = "太阳"
    case judgement = "审判"
    case world = "世界"
    
    var imageName: String {
        switch self {
        case .fool: return "tarot_card_1"
        case .magician: return "tarot_card_2"
        case .highPriestess: return "tarot_card_3"
        default: return "tarot_card_back"
        }
    }
}
