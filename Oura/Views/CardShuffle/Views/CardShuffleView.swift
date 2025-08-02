import SwiftUI

struct CardShuffleView: View {
    @StateObject private var store = CardShuffleStore()
    let onShuffleComplete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    @State private var hasStartedShuffle = false
    
    init(onShuffleComplete: (() -> Void)? = nil) {
        self.onShuffleComplete = onShuffleComplete
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                purpleGradientBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 导航栏
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // 标题区域
                    VStack(spacing: 16) {
                        Text("洗牌")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        if !hasStartedShuffle {
                            Text("点击开始按钮开始洗牌")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        } else {
                            Text("当你感觉足够时，点击停止")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    
                    // 卡牌洗牌区域
                    cardsSection
                        .onAppear {
                            store.setContainerSize(geometry.size)
                        }
                        .onChange(of: geometry.size) {
                            store.setContainerSize(geometry.size)
                        }
                    
                    Spacer()
                    
                    // 底部按钮
                    shuffleControlButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .onDisappear {
            store.stopShuffle()
            onShuffleComplete?()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    dismiss()
                }
                .foregroundStyle(.white)
            }
        }
    }
    
    private func adaptiveSpacing(for size: CGSize) -> CGFloat {
        if size.width > size.height {
            return size.height * 0.05
        } else {
            return 40
        }
    }
    
    private func adaptivePadding(for size: CGSize) -> CGFloat {
        if size.width > size.height {
            return size.width * 0.1
        } else if size.width > 600 {
            return size.width * 0.08
        } else {
            return 30
        }
    }
    
    private var purpleGradientBackground: some View {
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
    

    
    private var cardsSection: some View {
        ZStack {
            // 卡牌区域背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            // 洗牌卡牌
            GeometryReader { geometry in
                ZStack {
                    ForEach(store.cards) { card in
                        ShuffleCardView(card: card)
                            .position(
                                x: geometry.size.width / 2 + card.position.x,
                                y: geometry.size.height / 2 + card.position.y
                            )
                            .rotationEffect(.degrees(card.rotation))
                            .zIndex(card.zIndex)
                    }
                }
            }
            .frame(height: 300)
        }
        .padding(.horizontal, 20)
    }
    
    private var shuffleControlButton: some View {
        Button(action: {
            if store.isShuffling {
                // 停止洗牌，完成流程
                store.stopShuffle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onShuffleComplete?()
                    dismiss()
                }
            } else {
                // 开始洗牌
                hasStartedShuffle = true
                store.startShuffle()
            }
        }) {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: store.isShuffling ? 
                            [Color.white] :
                            [Color.orange, Color.red.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 56)
                .overlay(
                    HStack(spacing: 8) {
                        if !hasStartedShuffle {
                            Image(systemName: "shuffle")
                                .font(.title3)
                        }
                        
                        Text(store.isShuffling ? "停止洗牌" : (hasStartedShuffle ? "停止洗牌" : "开始洗牌"))
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(store.isShuffling ? .blue : .white)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(store.isShuffling ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: store.isShuffling)
    }
}

#Preview {
    CardShuffleView(onShuffleComplete: nil)
}