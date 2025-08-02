import SwiftUI
import Foundation

class BreathingStore: ObservableObject {
    @Published var hasStarted: Bool = false
    @Published var isCompleted: Bool = false
    @Published var currentCycle: Int = 0
    @Published var breathingScale: CGFloat = 1.0
    @Published var breathingText: String
    
    @Published private var isInhaling: Bool = true
    private var breathingTimer: Timer?
    
    static let totalCycles = 2
    private let breathingDuration: TimeInterval = 4.5
    
    init() {
        self.breathingText = LocalizationKeys.Status.readyToStart.localized
    }
    
    func startBreathing(onComplete: (() -> Void)? = nil) {
        hasStarted = true
        currentCycle = 0
        self.onComplete = onComplete
        startBreathingCycle()
    }
    
    private var onComplete: (() -> Void)?
    
    func completeBreathing(onComplete: (() -> Void)? = nil) {
        stopBreathing()
        isCompleted = true
        breathingText = LocalizationKeys.Status.completed.localized
        
        withAnimation(.easeOut(duration: 0.5)) {
            breathingScale = 1.3
        }
        if let onComplete = onComplete {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onComplete()
            }
        }
    }
    
    func stopBreathing() {
        breathingTimer?.invalidate()
        breathingTimer = nil
    }
    
    private func startBreathingCycle() {
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateBreathingAnimation()
        }
    }
    
    private func updateBreathingAnimation() {
        let cycleProgress = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: breathingDuration * 2)
        
        if cycleProgress < breathingDuration {
            if !isInhaling {
                isInhaling = true
                currentCycle += 1
            }
            breathingText = LocalizationKeys.Breathing.Status.inhale.localized
            let progress = cycleProgress / breathingDuration
            let smoothProgress = easeInOutSine(progress)
            breathingScale = 1.0 + (smoothProgress * 0.5)
        } else {
            isInhaling = false
            breathingText = LocalizationKeys.Breathing.Status.exhale.localized
            let progress = (cycleProgress - breathingDuration) / breathingDuration
            let smoothProgress = easeInOutSine(progress)
            breathingScale = 1.5 - (smoothProgress * 0.5)
            
            if progress > 0.95 && currentCycle >= Self.totalCycles {
                completeBreathing(onComplete: onComplete)
            }
        }
    }
    
    private func easeInOutSine(_ t: Double) -> Double {
        return -(cos(.pi * t) - 1) / 2
    }
    
    private func easeInOutCubic(_ t: Double) -> Double {
        if t < 0.5 {
            return 4 * t * t * t
        } else {
            let f = t - 1
            return 1 + 4 * f * f * f
        }
    }
}