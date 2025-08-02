import SwiftUI
import UIKit

private struct OfferingCard: Identifiable {
    let id: Int
    let initialRotation: Angle
    let initialOffset: CGSize
    var isCharged: Bool = false
    var isReleased: Bool = false
    var releaseAngle: Angle = .degrees(.random(in: -90...90))
    var releaseOffset: CGSize = .zero
}

private struct OfferingCardView: View {
    @Binding var card: OfferingCard
    
    @State private var continuousShake: Angle = .zero
    
    var body: some View {
        TarotCardView(cardType: .majorArcana(.fool), isRevealed: false, size: CGSize(width: 80, height: 130))
            .rotationEffect(card.initialRotation)
            .offset(card.initialOffset)
            .shadow(color: card.isCharged ? .yellow.opacity(0.8) : .black.opacity(0.5), radius: card.isCharged ? 20 : 5)
            .rotationEffect(continuousShake)
            .offset(card.isReleased ? card.releaseOffset : .zero)
            .rotationEffect(card.isReleased ? card.releaseAngle : .zero)
            .zIndex(card.isCharged ? 100 : Double(card.id))
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: card.isReleased)
            .onChange(of: card.isCharged) { _, isNowCharged in
                if isNowCharged {
                    let haptic = UIImpactFeedbackGenerator(style: .soft)
                    haptic.impactOccurred(intensity: 0.7)
                    withAnimation(.linear(duration: 0.05).repeatForever(autoreverses: true)) {
                        continuousShake = .degrees(3)
                    }
                } else {
                    withAnimation(.spring()) {
                        continuousShake = .zero
                    }
                }
            }
    }
}

struct ConnectionView: View {
    let onComplete: () -> Void
    
    @StateObject private var store = ConnectionStore()
    @State private var cards: [OfferingCard] = []
    @State private var gestureTimer: Timer?
    @State private var cardReleaseOrder: [Int] = []
    
    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerText
                    .zIndex(100)
                Spacer()
                connectionArea
                statusText.padding(.top, 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .onAppear(perform: setupCards)
        .onDisappear(perform: store.stopAllAnimations)
        .onChange(of: store.releasedCardCount) { _, count in
            guard count > 0 && count <= cardReleaseOrder.count else { return }
            
            let cardIndexToRelease = cardReleaseOrder[count - 1]
            
            cards[cardIndexToRelease].isCharged = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                guard cardIndexToRelease < cards.count, cards[cardIndexToRelease].isCharged else { return }
                
                cards[cardIndexToRelease].isReleased = true
                let angle = Angle.degrees(.random(in: 0...360))
                cards[cardIndexToRelease].releaseOffset = CGSize(width: cos(angle.radians) * 1200, height: sin(angle.radians) * 1200)
            }
        }
    }
    
    private func setupCards() {
        cards = (0..<ConnectionStore.totalCards).map { i in
            OfferingCard(
                id: i,
                initialRotation: .degrees(.random(in: -45...45)),
                initialOffset: CGSize(width: .random(in: -120...120), height: .random(in: -180...180))
            )
        }
        cardReleaseOrder = Array(0..<ConnectionStore.totalCards).shuffled()
    }
    
    private func resetState() {
        store.stopConnection()
        setupCards()
    }
    
    private var headerText: some View {
        VStack(spacing: 16) {
            Text(localized: LocalizationKeys.Connection.title)
                .font(.largeTitle).fontWeight(.bold).foregroundStyle(.white)
            
            VStack(spacing: 12) {
                if !store.isConnecting {
                    Text(localized: LocalizationKeys.Connection.instruction)
                        .font(.title3).fontWeight(.medium).foregroundStyle(.white.opacity(0.9))
                    Text(localized: LocalizationKeys.Connection.energyText)
                        .font(.body).foregroundStyle(.white.opacity(0.7))
                } else {
                    Text(localized: LocalizationKeys.Connection.connectingCards)
                        .font(.title3).fontWeight(.medium).foregroundStyle(.orange)
                    Text(localized: LocalizationKeys.Connection.feelEnergy)
                        .font(.body).foregroundStyle(.orange.opacity(0.8))
                }
            }
            .multilineTextAlignment(.center)
            .frame(minHeight: 100)
            .padding(.horizontal, 30)
        }
        .padding(.top, 40)
    }
    
    private var connectionArea: some View {
        ZStack {
            ForEach($cards) { $card in
                OfferingCardView(card: $card)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if gestureTimer == nil && !store.isConnecting {
                        gestureTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                            store.startConnection(onComplete: onComplete)
                        }
                    }
                }
                .onEnded { _ in
                    gestureTimer?.invalidate()
                    gestureTimer = nil
                    if store.isConnecting {
                        resetState()
                    }
                }
        )
        .frame(height: 400)
    }
    
    private var statusText: some View {
        VStack(spacing: 16) {
            if !store.isConnecting {
                Text(localized: LocalizationKeys.Connection.longPressStart)
                    .font(.headline).foregroundStyle(.white.opacity(0.8))
            }
            
            Text(store.isConnecting ? LocalizationKeys.Connection.keepPressing.localized : LocalizationKeys.Connection.Status.releaseWarning.localized)
                .font(.caption).foregroundStyle(.white.opacity(0.7))
        }
        .frame(height: 60)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.15, green: 0.15, blue: 0.2), Color(red: 0.2, green: 0.15, blue: 0.25)], startPoint: .top, endPoint: .bottom)
    }
}

#Preview {
    ConnectionView { print("Connection completed") }
}
