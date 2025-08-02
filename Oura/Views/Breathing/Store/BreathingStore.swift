import SwiftUI
import Foundation

enum BreathingPhase: CaseIterable {
    case inhale, hold, exhale
}

class BreathingStore: ObservableObject {
    @Published var hasStarted: Bool = false
    @Published var isCompleted: Bool = false
    @Published var currentCycle: Int = 0
    @Published var breathingText: String
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var phaseProgress: Double = 0.0
    
    private var breathingTimer: Timer?
    private var onComplete: (() -> Void)?
    private var startTime: Date?
    
    private let inhaleHaptic = UIImpactFeedbackGenerator(style: .light)
    private let holdHaptic = UIImpactFeedbackGenerator(style: .rigid)
    private let exhaleHaptic = UIImpactFeedbackGenerator(style: .soft)
    
    static let totalCycles = 3
    let inhaleDuration: TimeInterval = 4.0
    let holdDuration: TimeInterval = 2.0
    let exhaleDuration: TimeInterval = 6.0
    
    private var totalCycleDuration: TimeInterval {
        inhaleDuration + holdDuration + exhaleDuration
    }
    
    private var totalDuration: TimeInterval {
        totalCycleDuration * Double(Self.totalCycles)
    }
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
        self.breathingText = LocalizationKeys.Status.readyToStart.localized
        updatePhase(to: .inhale, initial: true)
        inhaleHaptic.prepare()
        holdHaptic.prepare()
        exhaleHaptic.prepare()
    }
    
    func startBreathing() {
        guard !hasStarted else { return }
        
        hasStarted = true
        startTime = Date()
        updatePhase(to: .inhale)
        startBreathingCycle()
    }
    
    func completeBreathing(isSkipped: Bool = false) {
        guard !isCompleted else { return }
        stopBreathing()
        isCompleted = true
        
        if isSkipped {
            onComplete?()
            return
        }
        
        breathingText = LocalizationKeys.Status.completed.localized
        let delay = 0.5
        
        withAnimation(.easeOut(duration: 0.6)) {
            phaseProgress = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.onComplete?()
        }
    }
    
    func stopBreathing() {
        breathingTimer?.invalidate()
        breathingTimer = nil
    }
    
    private func startBreathingCycle() {
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            self?.updateBreathingAnimation()
        }
    }
    
    private func updateBreathingAnimation() {
        guard let startTime = startTime else { return }
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        if elapsedTime >= totalDuration {
            if !isCompleted { completeBreathing() }
            return
        }
        
        currentCycle = Int(floor(elapsedTime / totalCycleDuration)) + 1
        let cycleProgress = elapsedTime.truncatingRemainder(dividingBy: totalCycleDuration)
        
        if cycleProgress < inhaleDuration {
            if currentPhase != .inhale { updatePhase(to: .inhale) }
            phaseProgress = easeInOut(cycleProgress / inhaleDuration)
        } else if cycleProgress < inhaleDuration + holdDuration {
            if currentPhase != .hold { updatePhase(to: .hold) }
            phaseProgress = 1.0
        } else {
            if currentPhase != .exhale { updatePhase(to: .exhale) }
            phaseProgress = 1.0 - easeInOut((cycleProgress - inhaleDuration - holdDuration) / exhaleDuration)
        }
    }
    
    private func updatePhase(to newPhase: BreathingPhase, initial: Bool = false) {
        currentPhase = newPhase
        
        if !initial {
            switch newPhase {
            case .inhale:
                breathingText = LocalizationKeys.Breathing.Status.inhale.localized
                inhaleHaptic.impactOccurred()
            case .hold:
                breathingText = LocalizationKeys.Breathing.Status.hold.localized
                holdHaptic.impactOccurred(intensity: 0.7)
            case .exhale:
                breathingText = LocalizationKeys.Breathing.Status.exhale.localized
                exhaleHaptic.impactOccurred()
            }
        } else {
            breathingText = LocalizationKeys.Status.readyToStart.localized
        }
    }
    
    private func easeInOut(_ t: Double) -> Double {
        return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }
}