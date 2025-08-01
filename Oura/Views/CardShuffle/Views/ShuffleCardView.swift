import SwiftUI

struct ShuffleCardView: View {
    let card: ShuffleCard
    
    var body: some View {
        TarotCardView(
            cardType: .fool,
            isRevealed: false,
            size: card.size,
            onTap: nil
        )
        .shadow(
            color: card.shouldShowShadow ? .black.opacity(0.3) : .clear,
            radius: card.shouldShowShadow ? 8 : 0,
            x: card.shouldShowShadow ? 2 : 0,
            y: card.shouldShowShadow ? 4 : 0
        )
    }
}

#Preview {
    ShuffleCardView(card: ShuffleCard())
}
