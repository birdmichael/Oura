import SwiftUI

struct TarotCardView: View {
    let cardType: TarotCardType
    let isRevealed: Bool
    let size: CGSize
    let onTap: (() -> Void)?
    
    init(
        cardType: TarotCardType,
        isRevealed: Bool = false,
        size: CGSize = CGSize(width: 80, height: 120),
        onTap: (() -> Void)? = nil
    ) {
        self.cardType = cardType
        self.isRevealed = isRevealed
        self.size = size
        self.onTap = onTap
    }
    
    var body: some View {
        let cardContent = ZStack {
            if isRevealed {
                cardFront
            } else {
                cardBack
            }
        }
        .frame(width: size.width, height: size.height)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRevealed)
        
        if let onTap = onTap {
            Button(action: onTap) {
                cardContent
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            cardContent
        }
    }
    
    private var cardBack: some View {
        Image("card_bg")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: size.width * 0.15))
            
    }
    
    private var cardFront: some View {
        VStack(spacing: 8) {
            Text(cardType.category.localizedName)
                .font(.system(size: size.width * 0.1, weight: .light))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Text(cardType.localizedName)
                .font(.system(size: size.width * 0.12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
            
            Spacer()
        }
        .padding(.top, size.height * 0.15)
        .padding(.horizontal, size.width * 0.1)
        .frame(width: size.width, height: size.height)
        .background(
            LinearGradient(
                colors: [
                    categoryColor.opacity(0.8),
                    categoryColor.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: size.width * 0.15))
        .overlay(
            RoundedRectangle(cornerRadius: size.width * 0.15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var categoryColor: Color {
        switch cardType {
        case .majorArcana:
            return .purple
        case .minorArcana(let suit, _):
            switch suit {
            case .wands:
                return .red
            case .cups:
                return .blue
            case .swords:
                return .gray
            case .pentacles:
                return .green
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            TarotCardView(
                cardType: .fool,
                isRevealed: false,
                size: CGSize(width: 80, height: 120)
            )
            
            TarotCardView(
                cardType: .fool,
                isRevealed: true,
                size: CGSize(width: 80, height: 120)
            )
        }
        
        HStack(spacing: 20) {
            TarotCardView(
                cardType: .aceOfWands,
                isRevealed: true,
                size: CGSize(width: 80, height: 120)
            )
            
            TarotCardView(
                cardType: .aceOfCups,
                isRevealed: true,
                size: CGSize(width: 80, height: 120)
            )
            
            TarotCardView(
                cardType: TarotCardType.minorArcana(suit: .swords, rank: .five),
                isRevealed: true,
                size: CGSize(width: 80, height: 120)
            )
            
            TarotCardView(
                cardType: .aceOfPentacles,
                isRevealed: true,
                size: CGSize(width: 80, height: 120)
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
}
