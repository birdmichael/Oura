import Foundation
import SwiftUI

@MainActor
class CardDrawingStore: ObservableObject, CardDrawingStoreProtocol {
    @Published var currentSpread: any TarotSpread
    @Published var selectedCardIndex: Int?
    @Published var isReadingGenerated = false
    @Published var nextCardIndex: Int = 0
    @Published var revealedCount: Int = 0
    
    private let availableCards = TarotCardType.allCases
    
    init(spreadType: TarotSpreadType = .relationship) {
        self.currentSpread = UniversalTarotSpread(spreadType: spreadType)
        generateReading()
    }
    
    func generateReading() {
        let shuffledCards = availableCards.shuffled()
        
        currentSpread.cards = Array(shuffledCards.prefix(currentSpread.positions.count)).map { cardType in
            TarotCardModel(cardType: cardType)
        }
        
        isReadingGenerated = true
    }
    
    func selectCard(at index: Int) {
        guard index < currentSpread.cards.count,
              index == nextCardIndex else { return }
        
        selectedCardIndex = index
        
        if var card = currentSpread.cards[index] as? TarotCardModel {
            card.isRevealed = true
            currentSpread.cards[index] = card
            
            revealedCount += 1
            nextCardIndex = revealedCount < currentSpread.cards.count ? revealedCount : nextCardIndex
        }
    }
    
    func resetReading() {
        selectedCardIndex = nil
        isReadingGenerated = false
        nextCardIndex = 0
        revealedCount = 0
        
        if let universalSpread = currentSpread as? UniversalTarotSpread {
            currentSpread = UniversalTarotSpread(spreadType: universalSpread.spreadType)
        }
        generateReading()
    }
    
    func switchToSpread(_ spreadType: TarotSpreadType) {
        selectedCardIndex = nil
        isReadingGenerated = false
        nextCardIndex = 0
        revealedCount = 0
        
        currentSpread = UniversalTarotSpread(spreadType: spreadType)
        generateReading()
    }
    
    func switchToSpread<T: TarotSpread>(_ spreadType: T.Type) {
        // 保持向后兼容
        switchToSpread(.relationship)
    }
}