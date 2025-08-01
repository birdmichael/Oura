import Foundation
import SwiftUI

@MainActor
protocol CardDrawingStoreProtocol: ObservableObject {
    var currentSpread: any TarotSpread { get set }
    var selectedCardIndex: Int? { get set }
    var isReadingGenerated: Bool { get set }
    var nextCardIndex: Int { get set }
    var revealedCount: Int { get set }
    
    func generateReading()
    func selectCard(at index: Int)
    func resetReading()
    func switchToSpread<T: TarotSpread>(_ spreadType: T.Type)
}

@MainActor 
protocol CardShuffleStoreProtocol: ObservableObject {
    var cards: [ShuffleCard] { get set }
    var isShuffling: Bool { get set }
    
    func startShuffle()
    func stopShuffle()
    func generateShuffleCards()
    func updateCardPositions()
    func setContainerSize(_ size: CGSize)
}

struct ShuffleCard: Identifiable {
    let id = UUID()
    var position: CGPoint
    var rotation: Double
    var zIndex: Double
    let size: CGSize
    var shouldShowShadow: Bool
    
    init(position: CGPoint = .zero, rotation: Double = 0, zIndex: Double = 0, size: CGSize = CGSize(width: 50, height: 80), shouldShowShadow: Bool = true) {
        self.position = position
        self.rotation = rotation
        self.zIndex = zIndex
        self.size = size
        self.shouldShowShadow = shouldShowShadow
    }
}