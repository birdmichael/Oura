import SwiftUI
import UIKit
import Foundation

class ConnectionStore: ObservableObject {
    @Published var connectionProgress: Double = 0.0
    @Published var isConnecting: Bool = false
    @Published var pulseScale: CGFloat = 1.0
    
    private var connectionTimer: Timer?
    private var pulseTimer: Timer?
    private var vibrationTimer: Timer?
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    private let connectionDuration: TimeInterval = 5.0
    
    init() {
        hapticFeedback.prepare()
    }
    
    func startConnection(onComplete: (() -> Void)? = nil) {
        guard !isConnecting else { return }
        
        isConnecting = true
        connectionProgress = 0.0
        hapticFeedback.impactOccurred()
        
        // 开始随机震动
        startRandomVibration()
        
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // 随机化进度增长速度 (0.8-1.2倍)
            let randomMultiplier = Double.random(in: 0.8...1.2)
            let baseIncrement = 0.1 / self.connectionDuration
            self.connectionProgress += baseIncrement * randomMultiplier
            
            if self.connectionProgress >= 1.0 {
                self.completeConnection(onComplete: onComplete)
            }
        }
    }
    
    func stopConnection() {
        guard isConnecting else { return }
        
        // 松手重新开始
        isConnecting = false
        connectionProgress = 0.0
        connectionTimer?.invalidate()
        connectionTimer = nil
        stopRandomVibration()
        
        // 轻微震动提示需要重新开始
        let lightHaptic = UIImpactFeedbackGenerator(style: .light)
        lightHaptic.impactOccurred()
    }
    
    func completeConnection(onComplete: (() -> Void)? = nil) {
        connectionTimer?.invalidate()
        connectionTimer = nil
        stopRandomVibration()
        
        // 连接完成的强烈震动序列
        performCompletionHaptics()
        
        // 延迟后调用完成回调
        if let onComplete = onComplete {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onComplete()
            }
        }
    }
    
    func startPulseAnimation() {
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            let time = Date().timeIntervalSince1970
            self.pulseScale = 1.0 + sin(time * 1.2) * 0.04
        }
    }
    
    func stopAllAnimations() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        connectionTimer?.invalidate()
        connectionTimer = nil
        stopRandomVibration()
    }
    
    func handlePressChange(_ isPressing: Bool, onComplete: @escaping () -> Void) {
        if isPressing {
            startConnection(onComplete: onComplete)
        } else {
            stopConnection()
        }
    }
    
    // MARK: - Private Methods
    
    private func startRandomVibration() {
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // 随机时间间隔 (0.15-0.4秒)
            if Bool.random() && Double.random(in: 0.0...1.0) < 0.3 {
                let vibrationTypes: [UIImpactFeedbackGenerator.FeedbackStyle] = [.heavy, .rigid, .medium, .heavy]
                let randomType = vibrationTypes.randomElement() ?? .heavy
                let randomHaptic = UIImpactFeedbackGenerator(style: randomType)
                randomHaptic.impactOccurred()
            }
        }
    }
    
    private func stopRandomVibration() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    private func performCompletionHaptics() {
        let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
        heavyHaptic.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            heavyHaptic.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            heavyHaptic.impactOccurred()
        }
    }
}