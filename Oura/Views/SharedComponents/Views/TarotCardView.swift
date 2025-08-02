import SwiftUI

/// 塔罗牌视图组件 - 通用的卡牌显示组件
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
    
    // MARK: - Card Front
    private var cardFront: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [Color.white, Color.white.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
            .overlay(
                VStack(spacing: 8) {
                    // 卡牌图片区域
                    cardImageSection
                    
                    // 卡牌名称
                    cardNameSection
                }
                .padding(8)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Card Back
    private var cardBack: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.1, blue: 0.3),
                        Color(red: 0.25, green: 0.15, blue: 0.4),
                        Color(red: 0.15, green: 0.1, blue: 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.6), Color.orange.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            )
            .overlay(
                cardBackPattern
            )
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Card Back Pattern
    private var cardBackPattern: some View {
        ZStack {
            // 中心神秘符号
            Image(systemName: "sparkles")
                .font(.system(size: min(size.width, size.height) * 0.3))
                .foregroundStyle(Color.orange.opacity(0.8))
            
            // 装饰圆圈
            Circle()
                .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                .frame(width: min(size.width, size.height) * 0.6)
            
            Circle()
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                .frame(width: min(size.width, size.height) * 0.8)
            
            // 角落装饰
            ForEach(0..<4, id: \.self) { corner in
                Image(systemName: "diamond.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.orange.opacity(0.6))
                    .offset(cornerOffset(for: corner))
            }
        }
    }
    
    // MARK: - Card Image Section
    private var cardImageSection: some View {
        Group {
            if let imageName = cardImageName {
                AsyncImage(url: URL(string: imageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(Color.gray)
                        )
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(Color.gray)
                    )
            }
        }
        .frame(height: size.height * 0.6)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Card Name Section
    private var cardNameSection: some View {
        VStack(spacing: 2) {
            Text(cardType.localizedName)
                .font(.system(size: min(size.width * 0.08, 12), weight: .semibold))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
            
            if case .minorArcana(let suit, _) = cardType {
                Text("\(suit.localizedName)")
                    .font(.system(size: min(size.width * 0.06, 10), weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var cardImageName: String? {
        // 根据实际的图片资源返回图片名称
        // 这里可以根据 cardType 返回对应的图片资源名
        switch cardType {
        case .majorArcana(let majorCard):
            return majorCard.imageName
        case .minorArcana(let suit, let rank):
            return "\(rank.rawValue)_of_\(suit.rawValue)"
        }
    }
    
    private func cornerOffset(for corner: Int) -> CGSize {
        let padding: CGFloat = 8
        let halfWidth = size.width / 2 - padding
        let halfHeight = size.height / 2 - padding
        
        switch corner {
        case 0: return CGSize(width: -halfWidth, height: -halfHeight) // 左上
        case 1: return CGSize(width: halfWidth, height: -halfHeight)  // 右上
        case 2: return CGSize(width: -halfWidth, height: halfHeight)  // 左下
        case 3: return CGSize(width: halfWidth, height: halfHeight)   // 右下
        default: return CGSize.zero
        }
    }
}

// MARK: - Preview
#Preview("Tarot Card - Back") {
    HStack(spacing: 20) {
        TarotCardView(
            cardType: .majorArcana(.fool),
            isRevealed: false,
            size: CGSize(width: 100, height: 150)
        )
        
        TarotCardView(
            cardType: .majorArcana(.fool),
            isRevealed: true,
            size: CGSize(width: 100, height: 150)
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}