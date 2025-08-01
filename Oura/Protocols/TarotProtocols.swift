import Foundation

protocol TarotCard {
    var id: UUID { get }
    var name: String { get }
    var imageName: String { get }
    var isRevealed: Bool { get }
}

protocol TarotSpread {
    var id: UUID { get }
    var title: String { get }
    var subtitle: String { get }
    var instruction: String { get }
    var additionalInfo: String { get }
    var positions: [TarotPosition] { get }
    var cards: [any TarotCard] { get set }
}

protocol TarotPosition {
    var id: UUID { get }
    var name: String { get }
    var index: Int { get }
}