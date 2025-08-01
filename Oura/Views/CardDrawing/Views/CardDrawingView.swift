import SwiftUI

struct CardDrawingView: View {
    @StateObject private var store = CardDrawingStore()
    @State private var showingSpreadSelector = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: adaptiveSpacing(for: geometry.size)) {
                    headerSection
                    
                    cardsSection(in: geometry.size)
                    
                    Spacer()
                    
                    buttonSection
                }
                .padding(.horizontal, adaptivePadding(for: geometry.size))
                .padding(.top, 60)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func adaptiveSpacing(for size: CGSize) -> CGFloat {
        if size.width > size.height { // iPad横屏或其他宽屏设备
            return size.height * 0.05
        } else {
            return 40
        }
    }
    
    private func adaptivePadding(for size: CGSize) -> CGFloat {
        if size.width > size.height { // iPad横屏
            return size.width * 0.1
        } else if size.width > 600 { // iPad竖屏
            return size.width * 0.08
        } else { // iPhone
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
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .frame(maxWidth: .infinity)
                .overlay(
                    Image("love")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black.opacity(0.85))
                )
                .overlay(
                    VStack(spacing: 8) {
                        Text(store.currentSpread.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text(store.currentSpread.subtitle)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Text(store.currentSpread.instruction)
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                            .fontWeight(.medium)
                        
                        Text(store.currentSpread.additionalInfo)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Button(action: {
                            showingSpreadSelector = true
                        }) {
                            Text("更换牌阵")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func cardsSection(in size: CGSize) -> some View {
        let spreadType = (store.currentSpread as? UniversalTarotSpread)?.spreadType ?? .relationship
        let cardPositions = spreadType.cardPositions(in: size)
        
        return ZStack {
            ForEach(Array(cardPositions.enumerated()), id: \.offset) { index, cardPosition in
                if index < store.currentSpread.cards.count {
                    CardDrawingCardView(
                        card: store.currentSpread.cards[index],
                        position: store.currentSpread.positions[index],
                        isSelected: store.selectedCardIndex == index,
                        isNextCard: index == store.nextCardIndex,
                        canTap: index == store.nextCardIndex,
                        cardSize: spreadType.optimalCardSize(for: size.width * 0.85, layoutHeight: size.height * 0.4)
                    ) {
                        store.selectCard(at: index)
                    }
                    .offset(x: cardPosition.offset.x, y: cardPosition.offset.y)
                    .rotationEffect(.degrees(cardPosition.rotation))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cardPosition.offset)
                }
            }
        }
        .frame(height: layoutHeight(for: size, spreadType: spreadType))
    }
    

    
    private func layoutHeight(for size: CGSize, spreadType: TarotSpreadType) -> CGFloat {
        switch spreadType {
        case .single:
            return size.height * 0.25
        case .threeCard:
            return size.height * 0.3
        case .relationship:
            return size.height * 0.35
        case .celticCross:
            return size.height * 0.4
        case .yearlyReading:
            return size.height * 0.45
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            continueButton
        }
        .sheet(isPresented: $showingSpreadSelector) {
            SpreadSelectorView { spreadType in
                store.switchToSpread(spreadType)
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            store.resetReading()
        }) {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [.orange, .red.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 50)
                .overlay(
                    Text("继续")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(store.revealedCount > 0 ? 1.0 : 0.95)
        .opacity(store.revealedCount > 0 ? 1.0 : 0.7)
        .animation(.easeInOut(duration: 0.2), value: store.revealedCount)
    }
}

#Preview {
    CardDrawingView()
    // 英文显示
    .environment(\.locale, .init(identifier: "en"))
}
