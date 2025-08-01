import SwiftUI

struct CardDrawingCardView: View {
    let card: any TarotCard
    let position: any TarotPosition
    let isSelected: Bool
    let isNextCard: Bool
    let canTap: Bool
    let cardSize: CGSize
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let tarotCard = card as? TarotCardModel {
                    TarotCardView(
                        cardType: tarotCard.cardType,
                        isRevealed: card.isRevealed,
                        size: cardSize,
                        onTap: canTap ? onTap : nil
                    )
                } else {
                    Button(action: canTap ? onTap : {}) {
                        ZStack {
                            cardBackground
                                .frame(width: cardSize.width, height: cardSize.height)
                            
                            cardContent
                        }
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isNextCard)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: canTap)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!canTap)
                }
                
                if isNextCard && !card.isRevealed {
                    Image(systemName: "hand.tap.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: cardSize.width * 0.25))
                        .allowsHitTesting(false)
                }
            }
            
            Text(position.name)
                .font(.system(size: min(cardSize.width * 0.15, 12)))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
    
    private var cardBackground: some View {
        Image("card_bg")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: cardSize.width * 0.15))
    }
    
    private var cardContent: some View {
        Group {
            if card.isRevealed {
                Image(card.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardSize.width, height: cardSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: cardSize.width * 0.15))
            } else {
                EmptyView()
            }
        }
    }
    
    private var cardScale: CGFloat {
        if isSelected {
            return 1.1
        } else if isNextCard {
            return 1.05
        } else {
            return 1.0
        }
    }
    
    private var cardOpacity: Double {
        if card.isRevealed || canTap {
            return 1.0
        } else {
            return 0.6
        }
    }
}
