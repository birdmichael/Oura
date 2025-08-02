import SwiftUI
import UIKit

struct ConnectionView: View {
    let onComplete: () -> Void
    
    @StateObject private var store = ConnectionStore()
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部文字区域 - 固定位置 
                VStack(spacing: 16) {
                    Text(localized: LocalizationKeys.Connection.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    // 固定高度的内容区域
                    VStack(spacing: 12) {
                        if !store.isConnecting {
                            Text(localized: LocalizationKeys.Connection.instruction)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                            
                            Text(localized: LocalizationKeys.Connection.energyText)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                            
                            Text(localized: LocalizationKeys.Connection.longPressStart)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        } else {
                            Text(localized: LocalizationKeys.Connection.connectingCards)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.orange)
                                .multilineTextAlignment(.center)
                            
                            Text(localized: LocalizationKeys.Connection.feelEnergy)
                                .font(.body)
                                .foregroundStyle(.orange.opacity(0.8))
                                .multilineTextAlignment(.center)
                            
                            Text(localized: LocalizationKeys.Connection.keepPressing)
                                .font(.caption)
                                .foregroundStyle(.orange.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(height: 120) // 固定高度
                    .padding(.horizontal, 30)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // 卡牌连接区域
                cardConnectionArea
                
                Spacer()
                
                // 底部状态和进度
                statusSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .onAppear {
            store.startPulseAnimation()
        }
        .onDisappear {
            store.stopAllAnimations()
        }
    }
    

    
    private var cardConnectionArea: some View {
        ZStack {
            // 背景光晕效果 - 使用固定容器避免抖动
            Circle()
                .fill(
                    RadialGradient(
                        colors: store.isConnecting ? [.orange.opacity(0.3), .clear] : [.clear, .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(store.isConnecting ? 1.05 : 1.0)
                .opacity(store.isConnecting ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8), value: store.isConnecting)
            
            // 多张卡牌叠放效果
            ForEach(0..<5, id: \.self) { index in
                TarotCardView(
                    cardType: .majorArcana(.fool),
                    isRevealed: false,
                    size: CGSize(width: 140 - CGFloat(index * 8), height: 210 - CGFloat(index * 12))
                )
                .scaleEffect(store.pulseScale - CGFloat(index) * 0.02)
                .offset(
                    x: CGFloat(index * 3) + (store.isConnecting ? CGFloat(index % 2 == 0 ? 1 : -1) : 0),
                    y: CGFloat(index * -4) + (store.isConnecting ? CGFloat(index % 3 == 0 ? 1 : -1) : 0)
                )
                .rotationEffect(.degrees(Double(index) * 2 + (store.isConnecting ? Double(index % 2 == 0 ? 0.5 : -0.5) : 0)))
                .opacity(1.0 - Double(index) * 0.15)
                .shadow(
                    color: store.isConnecting ? .orange.opacity(0.4) : .black.opacity(0.2),
                    radius: store.isConnecting ? 12 : 4,
                    x: 0,
                    y: store.isConnecting ? 0 : 2
                )
            }
            
            // 最前面的主卡牌
            TarotCardView(
                cardType: .majorArcana(.fool),
                isRevealed: false,
                size: CGSize(width: 140, height: 210)
            )
            .scaleEffect(store.pulseScale)
            .shadow(
                color: store.isConnecting ? .orange.opacity(0.6) : .black.opacity(0.3),
                radius: store.isConnecting ? 16 : 6,
                x: 0,
                y: store.isConnecting ? 0 : 3
            )

            .onLongPressGesture(minimumDuration: 0.1) {
                // 长按完成
            } onPressingChanged: { isPressing in
                store.handlePressChange(isPressing, onComplete: onComplete)
            }
        }
    }
    
    private var statusSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                if store.isConnecting {
                    Text(localized: LocalizationKeys.Connection.Status.connecting, 
                         arguments: Int(store.connectionProgress * 100))
                        .font(.headline)
                        .foregroundStyle(.white)
                } else {
                    Text(localized: LocalizationKeys.Connection.Status.startInstruction)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                // 固定高度的进度条区域，避免跳动
                VStack(spacing: 8) {
                    if store.isConnecting {
                        progressBar
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 8)
                    }
                    
                    if store.isConnecting {
                        Text(localized: LocalizationKeys.Connection.Status.holdInstruction)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    } else {
                        Text(localized: LocalizationKeys.Connection.Status.releaseWarning)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 40)
            .frame(height: 100) // 固定高度，避免跳动
        }
    }
    
    private var progressBar: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.white.opacity(0.2))
            .frame(height: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(x: store.connectionProgress, y: 1.0, anchor: .leading)
                    .animation(.easeInOut(duration: 0.1), value: store.connectionProgress)
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
    ConnectionView {
        print("Connection completed")
    }
}