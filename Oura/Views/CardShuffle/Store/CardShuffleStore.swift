import Foundation
import SwiftUI
import UIKit

@MainActor
class CardShuffleStore: ObservableObject, CardShuffleStoreProtocol {
    @Published var cards: [ShuffleCard] = []
    @Published var isShuffling: Bool = false
    var shuffleTimer: Timer?
    
    private let cardCount = 40
    private let shuffleInterval: TimeInterval = 1
    private var containerSize: CGSize = .zero
    private let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        generateShuffleCards()
        impactFeedback.prepare()
        lightFeedback.prepare()
        mediumFeedback.prepare()
    }
    
    func generateShuffleCards() {
        cards = (0..<cardCount).map { index in
            ShuffleCard(
                position: randomPosition(),
                rotation: randomInitialRotation(),
                zIndex: Double(index)
            )
        }
    }
    
    func startShuffle() {
        guard !isShuffling else { return }
        
        isShuffling = true
        impactFeedback.prepare()
        
        shuffleTimer = Timer.scheduledTimer(withTimeInterval: shuffleInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCardPositions()
            }
        }
    }
    
    func stopShuffle() {
        isShuffling = false
        shuffleTimer?.invalidate()
        shuffleTimer = nil
        
        animateCardsToCenter()
    }
    
    func updateCardPositions() {
        triggerBreathingVibration()
        
        withAnimation(.spring(response: 0.9, dampingFraction: 0.7, blendDuration: 0.1)) {
            let shuffledIndices = cards.indices.shuffled()
            
            for (newZIndex, index) in shuffledIndices.enumerated() {
                cards[index].position = randomPosition()
                cards[index].rotation += randomRotationIncrement()
                cards[index].zIndex = Double(newZIndex)
                cards[index].shouldShowShadow = true
            }
        }
    }
    
    func setContainerSize(_ size: CGSize) {
        containerSize = size
        if !cards.isEmpty {
            updateCardPositions()
        }
    }
    
    private func randomPosition() -> CGPoint {
        let cardWidth: CGFloat = 50
        let cardHeight: CGFloat = 80
        
        let availableWidth = max(350, containerSize.width * 0.85)
        let availableHeight = max(250, containerSize.height * 0.65)
        
        let minX = -availableWidth / 2 + cardWidth / 2
        let maxX = availableWidth / 2 - cardWidth / 2
        let minY = -availableHeight / 2 + cardHeight / 2
        let maxY = availableHeight / 2 - cardHeight / 2
        
        return CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }
    
    private func randomInitialRotation() -> Double {
        Double.random(in: -90...90)
    }
    
    private func randomRotationIncrement() -> Double {
        Double.random(in: -30...30)
    }
    
    private func triggerBreathingVibration() {
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.lightFeedback.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.mediumFeedback.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            self?.lightFeedback.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.impactFeedback.impactOccurred()
        }
    }
    
    private func animateCardsToCenter() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8, blendDuration: 0.2)) {
            for index in cards.indices {
                cards[index].position = centerPosition()
                cards[index].rotation = 0
                cards[index].zIndex = Double(index)
                cards[index].shouldShowShadow = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.animateCardsToRightSequentially()
        }
    }
    
    private func animateCardsToRightSequentially() {
        let screenWidth = max(400, containerSize.width)
        let rightPosition = CGPoint(x: screenWidth, y: 0)
        let delayInterval: TimeInterval = 0.005
        
        for (index, _) in cards.enumerated() {
            let delay = TimeInterval(index) * delayInterval
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                
                withAnimation(.easeIn(duration: 0.25)) {
                    self.cards[index].position = rightPosition
                }
            }
        }
        
        let totalAnimationTime = TimeInterval(cards.count) * delayInterval + 0.25
        DispatchQueue.main.asyncAfter(deadline: .now() + totalAnimationTime) { [weak self] in
            self?.resetCardsPosition()
        }
    }
    
    private func resetCardsPosition() {
        generateShuffleCards()
    }
    
    private func centerPosition() -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    deinit {
        shuffleTimer?.invalidate()
    }
}
