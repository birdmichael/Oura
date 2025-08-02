import Foundation
import SwiftUI
import UIKit

@MainActor
class CardDrawingStore: ObservableObject {
    @Published var currentSpread: any TarotSpread
    @Published var selectedCardIndex: Int?
    @Published var isReadingGenerated = false
    @Published var nextCardIndex: Int = 0
    @Published var revealedCount: Int = 0
    @Published var currentPhase: AppPhase = .preparation
    @Published var showingMagnifiedCard: Bool = false
    @Published var connectionProgress: Double = 0.0
    @Published var isBreathing: Bool = false
    @Published var breathingScale: CGFloat = 1.0
    @Published var isConnecting: Bool = false
    @Published var tarotReading: TarotReading?
    
    private let availableCards = TarotCardType.allCases
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    private var breathingTimer: Timer?
    private var connectionTimer: Timer?
    
    init(spreadType: TarotSpreadType = .relationship) {
        self.currentSpread = UniversalTarotSpread(spreadType: spreadType)
        hapticFeedback.prepare()
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
        guard currentPhase == .cardSelection,
              index < currentSpread.cards.count,
              index == nextCardIndex else { return }
        
        selectedCardIndex = index
        
        if var card = currentSpread.cards[index] as? TarotCardModel {
            card.isRevealed = true
            currentSpread.cards[index] = card
            
            revealedCount += 1
            if revealedCount < currentSpread.cards.count {
                nextCardIndex = revealedCount
            } else {

                generateTarotReading()
                currentPhase = .completed
            }
        }
    }
    
    func resetReading() {
        selectedCardIndex = nil
        isReadingGenerated = false
        nextCardIndex = 0
        revealedCount = 0
        currentPhase = .preparation
        showingMagnifiedCard = false
        connectionProgress = 0.0
        isBreathing = false
        breathingScale = 1.0
        isConnecting = false
        tarotReading = nil
        
        stopBreathingAnimation()
        stopConnectionProcess()
        
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
        currentPhase = .preparation
        showingMagnifiedCard = false
        connectionProgress = 0.0
        isBreathing = false
        breathingScale = 1.0
        isConnecting = false
        tarotReading = nil
        
        stopBreathingAnimation()
        stopConnectionProcess()
        
        currentSpread = UniversalTarotSpread(spreadType: spreadType)
        generateReading()
    }
    
    func switchToSpread<T: TarotSpread>(_ spreadType: T.Type) {

        switchToSpread(.relationship)
    }
    
    func startConnectingPhase() {
        currentPhase = .connection
        startBreathingAnimation()
    }
    
    func startShufflePhase() {
        currentPhase = .shuffling
    }
    
    func completeShufflePhase() {
        currentPhase = .cardSelection
    }
    
    func toggleCardMagnification() {
        showingMagnifiedCard.toggle()
    }
    
    func canTapCard(at index: Int) -> Bool {
        switch currentPhase {
        case .preparation:
            return false
        case .breathing:
            return false
        case .connection:
            return !isConnecting
        case .shuffling:
            return false
        case .cardSelection:
            return index == nextCardIndex || (currentSpread.cards[index].isRevealed && index == selectedCardIndex)
        case .completed:
            return currentSpread.cards[index].isRevealed
        }
    }
    

    
    func startBreathingAnimation() {
        isBreathing = true
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.isBreathing else { return }
                let time = Date().timeIntervalSince1970
                let breathingCycle = sin(time * 0.8) * 0.3 + 1.0
                self.breathingScale = CGFloat(breathingCycle)
                

                if Int(time * 0.8) % 4 == 0 && Int(time * 100) % 40 == 0 {
                    self.hapticFeedback.impactOccurred()
                }
            }
        }
    }
    
    func stopBreathingAnimation() {
        isBreathing = false
        breathingScale = 1.0
        breathingTimer?.invalidate()
        breathingTimer = nil
    }
    
    func startConnectionProcess() {
        guard currentPhase == .connection && !isConnecting else { return }
        
        isConnecting = true
        connectionProgress = 0.0
        hapticFeedback.impactOccurred()
        
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.isConnecting else { return }
                
                self.connectionProgress += 0.02
                

                if Int(self.connectionProgress * 100) % 25 == 0 {
                    self.hapticFeedback.impactOccurred()
                }
                
                if self.connectionProgress >= 1.0 {
                    self.completeConnection()
                }
            }
        }
    }
    
    func stopConnectionProcess() {
        isConnecting = false
        connectionProgress = 0.0
        connectionTimer?.invalidate()
        connectionTimer = nil
    }
    
    func completeConnection() {
        stopConnectionProcess()
        stopBreathingAnimation()
        

        let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
        heavyHaptic.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentPhase = .shuffling
        }
    }
    

    
    private func generateTarotReading() {
        let revealedCards = currentSpread.cards.compactMap { $0 as? TarotCardModel }.filter { $0.isRevealed }
        tarotReading = ReadingGenerator.generateReading(for: currentSpread, cards: revealedCards)
    }
    
    deinit {
        breathingTimer?.invalidate()
        connectionTimer?.invalidate()
    }
}