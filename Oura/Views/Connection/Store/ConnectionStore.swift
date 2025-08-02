import SwiftUI
import UIKit
import Foundation

class ConnectionStore: ObservableObject {
    @Published var isConnecting: Bool = false
    @Published var releasedCardCount: Int = 0
    
    private var releaseTimer: Timer?
    private var onComplete: (() -> Void)?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    private let softHaptic = UIImpactFeedbackGenerator(style: .soft)
    
    static let totalCards = 40
    
    init() {
        hapticFeedback.prepare()
        softHaptic.prepare()
    }
    
    func startConnection(onComplete: @escaping () -> Void) {
        guard !isConnecting else { return }
        
        self.onComplete = onComplete
        isConnecting = true
        releasedCardCount = 0
        
        scheduleNextRelease()
    }
    
    private func scheduleNextRelease() {
        guard isConnecting else { return }
        
        let interval = TimeInterval.random(in: 0.02...0.4)
        releaseTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.releaseNextCard()
        }
    }
    
    private func releaseNextCard() {
        guard isConnecting else { return }
        
        if releasedCardCount < Self.totalCards {
            releasedCardCount += 1
            softHaptic.impactOccurred(intensity: 0.6 + (Double(releasedCardCount) / Double(Self.totalCards)) * 0.4)
            scheduleNextRelease()
        } else {
            completeConnection()
        }
    }
    
    func stopConnection() {
        guard isConnecting else { return }
        
        isConnecting = false
        releaseTimer?.invalidate()
        releaseTimer = nil
        softHaptic.impactOccurred()
    }
    
    func completeConnection() {
        releaseTimer?.invalidate()
        releaseTimer = nil
        
        let completionHaptic = UIImpactFeedbackGenerator(style: .heavy)
        completionHaptic.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { completionHaptic.impactOccurred(intensity: 1.0) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { completionHaptic.impactOccurred(intensity: 1.0) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.onComplete?()
            self.isConnecting = false
        }
    }
    
    func stopAllAnimations() {
        releaseTimer?.invalidate()
        releaseTimer = nil
    }
}