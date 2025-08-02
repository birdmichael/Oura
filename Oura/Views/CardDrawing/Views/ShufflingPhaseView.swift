import SwiftUI

struct ShufflingPhaseView: View {
    let onComplete: () -> Void
    
    @StateObject private var shuffleStore = CardShuffleStore()
    @State private var hasStarted = false
    @State private var canComplete = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 标题 - 固定高度避免跳动
            VStack(spacing: 16) {
                Text(localized: LocalizationKeys.Shuffle.meditationTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                // 固定高度的内容区域
                VStack(spacing: 12) {
                    if !hasStarted {
                        Text(localized: LocalizationKeys.Shuffle.thinkQuestion)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.9))
                        
                        Text(localized: LocalizationKeys.Shuffle.energyFusion)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Text(localized: LocalizationKeys.Shuffle.whenReady)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    } else if shuffleStore.isShuffling {
                        Text(localized: LocalizationKeys.Shuffle.stayFocused)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.9))
                        
                        Text(localized: LocalizationKeys.Shuffle.stopWhenReady)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        // 占位文本保持高度一致
                        Text("")
                            .font(.caption)
                            .foregroundStyle(.clear)
                    } else {
                        Text(localized: LocalizationKeys.Shuffle.completed)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)
                        
                        Text(localized: LocalizationKeys.Shuffle.enterSelection)
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
            
            // 洗牌卡牌区域（不要方框）
            GeometryReader { geometry in
                ZStack {
                    ForEach(shuffleStore.cards) { card in
                        ShuffleCardView(card: card)
                            .position(
                                x: geometry.size.width / 2 + card.position.x,
                                y: geometry.size.height / 2 + card.position.y
                            )
                            .rotationEffect(.degrees(card.rotation))
                            .zIndex(card.zIndex)
                    }
                }
                .onAppear {
                    shuffleStore.setContainerSize(geometry.size)
                }
                .onChange(of: geometry.size) {
                    shuffleStore.setContainerSize(geometry.size)
                }
            }
            .frame(height: 300)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // 控制按钮 - 使用透明度避免跳动
            VStack(spacing: 8) {
                // 开始按钮
                Button(action: {
                    if !hasStarted {
                        hasStarted = true
                        shuffleStore.startShuffle()
                    } else if shuffleStore.isShuffling {
                        shuffleStore.stopShuffle()
                        // 延迟1秒后自动跳转
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onComplete()
                        }
                    }
                }) {
                    VStack(spacing: 8) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: shuffleStore.isShuffling ? 
                                        [.white] : 
                                        [.orange, .red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: shuffleStore.isShuffling ? "stop.fill" : "shuffle")
                                    .font(.title)
                                    .foregroundStyle(shuffleStore.isShuffling ? .red : .white)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Text(localized: shuffleStore.isShuffling ? LocalizationKeys.Shuffle.Button.stop : LocalizationKeys.Shuffle.Button.start)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                    }
                }
                .scaleEffect(shuffleStore.isShuffling ? 0.95 : 1.0)
                .opacity(hasStarted || !hasStarted ? 1.0 : 0.5) // 始终保持可见
                .animation(.easeInOut(duration: 0.3), value: shuffleStore.isShuffling)
                .animation(.easeInOut(duration: 0.3), value: hasStarted)
                .disabled(hasStarted && !shuffleStore.isShuffling && shuffleStore.cards.isEmpty)
            }
            .frame(height: 120) // 固定高度，避免跳动
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.15, blue: 0.2),
                    Color(red: 0.2, green: 0.15, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    ShufflingPhaseView {
        print("Shuffling completed")
    }
}