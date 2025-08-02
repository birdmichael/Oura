import SwiftUI

struct BreathingView: View {
    let onComplete: () -> Void
    
    @StateObject private var store = BreathingStore()
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 标题 - 固定高度避免跳动
                VStack(spacing: 16) {
                    Text(localized: LocalizationKeys.Breathing.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    // 固定高度的内容区域
                    VStack(spacing: 12) {
                        if !store.hasStarted {
                            Text(localized: LocalizationKeys.Breathing.instruction)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                            
                            Text(localized: LocalizationKeys.Breathing.focusMeditation)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                            
                            Text(localized: LocalizationKeys.Breathing.startPractice)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        } else if store.hasStarted && !store.isCompleted {
                            Text(localized: LocalizationKeys.Breathing.followRhythm)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                            
                            Text(localized: LocalizationKeys.Breathing.relaxBody)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                            
                            if store.hasStarted && !store.isCompleted {
                                let remaining = max(0, BreathingStore.totalCycles - store.currentCycle + 1)
                                if remaining > 0 {
                                    Text(localized: LocalizationKeys.Breathing.remainingCycles, arguments: remaining)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text("")
                                        .font(.caption)
                                        .foregroundStyle(.clear)
                                }
                            } else {
                                Text("")
                                    .font(.caption)
                                    .foregroundStyle(.clear)
                            }
                        } else {
                            Text(localized: LocalizationKeys.Breathing.practiceComplete)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.green)
                                .multilineTextAlignment(.center)
                            
                            Text(localized: LocalizationKeys.Breathing.enteringConnection)
                                .font(.body)
                                .foregroundStyle(.green.opacity(0.7))
                                .multilineTextAlignment(.center)
                            
                            // 占位文本保持高度一致
                            Text("")
                                .font(.caption)
                                .foregroundStyle(.clear)
                        }
                    }
                    .frame(height: 120) // 固定高度
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // 呼吸动画区域
                breathingAnimationView
                
                Spacer()
                
                // 底部按钮
                bottomButtonView
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .onDisappear {
            store.stopBreathing()
        }
    }
    
    private var breathingAnimationView: some View {
        ZStack {
            // 外圈装饰
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: CGFloat(200 + index * 60), height: CGFloat(200 + index * 60))
                    .scaleEffect(store.hasStarted ? store.breathingScale * (1.0 - CGFloat(index) * 0.1) : 1.0)
            }
            
            // 主呼吸圆圈
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: store.isCompleted ? [
                            Color.green.opacity(0.4),
                            Color.teal.opacity(0.2),
                            Color.clear
                        ] : [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(store.hasStarted ? store.breathingScale : 1.0)
                .overlay(
                    Circle()
                        .stroke(
                            store.isCompleted ? 
                                Color.green.opacity(0.8) : 
                                Color.white.opacity(0.6), 
                            lineWidth: 2
                        )
                        .scaleEffect(store.hasStarted ? store.breathingScale : 1.0)
                )
                .overlay(
                    // 简化的完成效果
                    Group {
                        if store.isCompleted {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.green.opacity(0.2), .clear],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 30
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .scaleEffect(store.isCompleted ? 1.0 : 0.8)
                                .opacity(store.isCompleted ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.5), value: store.isCompleted)
                        }
                    }
                )
            
            // 中心文字
            VStack(spacing: 8) {
                Text(store.breathingText)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)

            }
        }
    }
    
    private var bottomButtonView: some View {
        VStack {
            if !store.hasStarted {
                Button(action: {
                    store.startBreathing(onComplete: onComplete)
                }) {
                    buttonStyle(
                        colors: [.orange, .red.opacity(0.8)],
                        icon: "wind",
                        text: LocalizationKeys.Breathing.Button.start.localized
                    )
                }
            } else {
                // 占位符，保持高度一致，避免跳动
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 56)
            }
        }
        .padding(.horizontal, 40)
        .frame(minHeight: 80) // 固定最小高度
    }
    
    private func buttonStyle(colors: [Color], icon: String, text: String) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 56)
            .overlay(
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title3)
                    Text(text)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
            )
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.1, blue: 0.15),
                Color(red: 0.15, green: 0.15, blue: 0.2),
                Color(red: 0.2, green: 0.15, blue: 0.25)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    BreathingView { 
        print("Breathing completed")
    }
}