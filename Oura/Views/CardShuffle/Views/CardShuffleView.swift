import SwiftUI

struct CardShuffleView: View {
    @StateObject private var store = CardShuffleStore()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: adaptiveSpacing(for: geometry.size)) {
                    headerSection(for: geometry.size)
                    
                    Spacer()
                    
                    cardsSection
                    
                    Spacer()
                    
                    buttonSection
                }
                .padding(.horizontal, adaptivePadding(for: geometry.size))
                .padding(.top, 60)
                .padding(.bottom, 40)
            }
        }
        .onDisappear {
            store.stopShuffle()
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
    
    private func headerSection(for size: CGSize) -> some View {
        VStack(spacing: 16) {
            Text("shuffle.title")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text("shuffle.instruction")
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    private var cardsSection: some View {
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
            .onAppear {
                store.setContainerSize(geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                store.setContainerSize(newSize)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }
    
    private var buttonSection: some View {
        Button(action: {
            if store.isShuffling {
                store.stopShuffle()
            } else {
                store.startShuffle()
            }
        }) {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: store.isShuffling ? 
                            [.gray, .gray.opacity(0.8)] :
                            [.orange, .red.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 50)
                .overlay(
                    Text(store.isShuffling ? "shuffle.stop" : "shuffle.start")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(store.isShuffling ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: store.isShuffling)
    }
}

#Preview {
    CardShuffleView()
}