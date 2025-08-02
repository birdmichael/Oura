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