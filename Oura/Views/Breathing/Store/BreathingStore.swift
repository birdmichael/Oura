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
    private let breathingDuration: TimeInterval = 4.0
    
    init() {
        self.breathingText = LocalizationKeys.Status.readyToStart.localized
    }
    
    func startBreathing(onComplete: (() -> Void)? = nil) {
        hasStarted = true
        currentCycle = 0  // 从0开始计数
        self.onComplete = onComplete
        startBreathingCycle()
    }
    
    private var onComplete: (() -> Void)?
    
    func completeBreathing(onComplete: (() -> Void)? = nil) {
        stopBreathing()
        isCompleted = true
        breathingText = LocalizationKeys.Status.completed.localized
        
        // 简化完成动画，直接跳转到连接页面
        withAnimation(.easeOut(duration: 0.5)) {
            breathingScale = 1.3
        }
        
        // 立即跳转到连接页面
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
    
    // MARK: - Private Methods
    
    private func startBreathingCycle() {
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateBreathingAnimation()
        }
    }
    
    private func updateBreathingAnimation() {
        let cycleProgress = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: breathingDuration * 2)
        
        if cycleProgress < breathingDuration {
            // 吸气阶段
            if !isInhaling {
                // 刚开始新的吸气周期，从1开始计数
                isInhaling = true
                currentCycle += 1
            }
            breathingText = LocalizationKeys.Breathing.Status.inhale.localized
            let progress = cycleProgress / breathingDuration
            breathingScale = 1.0 + (progress * 0.4)
        } else {
            // 呼气阶段
            isInhaling = false
            breathingText = LocalizationKeys.Breathing.Status.exhale.localized
            let progress = (cycleProgress - breathingDuration) / breathingDuration
            breathingScale = 1.4 - (progress * 0.4)
            
            // 检查是否完成所有周期 (currentCycle从1开始计数到totalCycles)
            if progress > 0.95 && currentCycle >= Self.totalCycles {
                completeBreathing(onComplete: onComplete)
            }
        }
    }
}