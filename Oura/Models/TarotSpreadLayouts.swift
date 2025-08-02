import Foundation
import SwiftUI

enum TarotSpreadType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case single = "single"
    case threeCard = "three_card"
    case relationship = "relationship"
    case celticCross = "celtic_cross"
    case yearlyReading = "yearly_reading"
    
    var localizedTitle: String {
        switch self {
        case .single:
            return String(localized: "spread.single")
        case .threeCard:
            return String(localized:"spread.three_card")
        case .relationship:
            return String(localized:"spread.relationship")
        case .celticCross:
            return String(localized:"spread.celtic_cross")
        case .yearlyReading:
            return String(localized:"spread.yearly_reading")
        }
    }
    
    
    var cardCount: Int {
        switch self {
        case .single: return 1
        case .threeCard: return 3
        case .relationship: return 5
        case .celticCross: return 10
        case .yearlyReading: return 12
        }
    }
    
    var positions: [String] {
        switch self {
        case .single:
            return ["当前"]
        case .threeCard:
            return ["过去", "现在", "未来"]
        case .relationship:
            return ["自我", "对方", "关系现状", "潜在问题", "未来走向"]
        case .celticCross:
            return ["现状", "挑战", "远古过去", "近期过去", "可能未来", "近期未来", "内在态度", "外在影响", "希望恐惧", "最终结果"]
        case .yearlyReading:
            return ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
        }
    }
    
    var subtitle: String {
        switch self {
        case .single: return "专注你的问题"
        case .threeCard: return "时间之流的指引"
        case .relationship: return "在心中默念你的问题"
        case .celticCross: return "最经典的塔罗占卜"
        case .yearlyReading: return "全年运势预测"
        }
    }
    
    var instruction: String {
        switch self {
        case .single: return "抽取你的卡牌"
        case .threeCard: return "依次抽取三张卡"
        case .relationship: return "抽取你的第3张牌"
        case .celticCross: return "按顺序抽取十张卡"
        case .yearlyReading: return "为每个月抽取一张卡"
        }
    }
    
    var additionalInfo: String {
        switch self {
        case .single: return "抽取1张牌，探索当下"
        case .threeCard: return "抽取3张牌，了解过去现在未来"
        case .relationship: return "抽取5张牌，了解情感关系"
        case .celticCross: return "抽取10张牌，深入探索议题"
        case .yearlyReading: return "抽取12张牌，了解全年运势"
        }
    }
}

struct CardPosition {
    let index: Int
    let name: String
    let offset: CGPoint
    let rotation: Double
    
    init(index: Int, name: String, offset: CGPoint = .zero, rotation: Double = 0) {
        self.index = index
        self.name = name
        self.offset = offset
        self.rotation = rotation
    }
}

extension TarotSpreadType {
    func cardPositions(in size: CGSize) -> [CardPosition] {
        // 计算安全的布局区域，留出边距
        let layoutWidth = size.width * 0.85  // 85%的屏幕宽度
        let layoutHeight = size.height * 0.4 // 40%的屏幕高度
        
        let cardSize = optimalCardSize(for: layoutWidth, layoutHeight: layoutHeight)
        
        switch self {
        case .single:
            return [CardPosition(index: 0, name: positions[0])]
            
        case .threeCard:
            return triangleLayout(cardSize: cardSize, layoutBounds: CGSize(width: layoutWidth, height: layoutHeight))
            
        case .relationship:
            return pentagramLayout(cardSize: cardSize, layoutBounds: CGSize(width: layoutWidth, height: layoutHeight))
            
        case .celticCross:
            return celticCrossLayout(cardSize: cardSize, layoutBounds: CGSize(width: layoutWidth, height: layoutHeight))
            
        case .yearlyReading:
            return yearlyLayout(cardSize: cardSize, layoutBounds: CGSize(width: layoutWidth, height: layoutHeight))
        }
    }
    
    func optimalCardSize(for layoutWidth: CGFloat, layoutHeight: CGFloat) -> CGSize {
        let cardRatio: CGFloat = 1.4 // 标准塔罗牌比例
        
        switch self {
        case .single:
            let maxWidth = layoutWidth * 0.4
            let maxHeight = layoutHeight * 0.8
            let width = min(maxWidth, maxHeight / cardRatio)
            return CGSize(width: width, height: width * cardRatio)
            
        case .threeCard:
            // 三角形布局，需要考虑水平和垂直空间
            let maxWidth = layoutWidth * 0.25
            let maxHeight = layoutHeight * 0.6
            let width = min(maxWidth, maxHeight / cardRatio)
            return CGSize(width: width, height: width * cardRatio)
            
        case .relationship:
            // 五角星布局，需要圆形空间
            let diameter = min(layoutWidth, layoutHeight) * 0.8
            let maxCardWidth = diameter * 0.18
            return CGSize(width: maxCardWidth, height: maxCardWidth * cardRatio)
            
        case .celticCross:
            // 2排5列，需要紧凑布局
            let maxWidth = layoutWidth / 5.5  // 5张卡 + 间距
            let maxHeight = layoutHeight / 2.8 // 2排 + 间距
            let width = min(maxWidth, maxHeight / cardRatio)
            return CGSize(width: width, height: width * cardRatio)
            
        case .yearlyReading:
            // 3排4列，最紧凑布局
            let maxWidth = layoutWidth / 4.5  // 4张卡 + 间距
            let maxHeight = layoutHeight / 3.8 // 3排 + 间距
            let width = min(maxWidth, maxHeight / cardRatio)
            return CGSize(width: width, height: width * cardRatio)
        }
    }
    
    private func triangleLayout(cardSize: CGSize, layoutBounds: CGSize) -> [CardPosition] {
        let spacing: CGFloat = cardSize.width * 0.4
        let triangleHeight = cardSize.height * 1.2
        
        return [
            // 顶部卡片
            CardPosition(index: 0, name: positions[0], 
                        offset: CGPoint(x: 0, y: -triangleHeight * 0.3)),
            // 左下卡片
            CardPosition(index: 1, name: positions[1], 
                        offset: CGPoint(x: -(cardSize.width + spacing) * 0.5, y: triangleHeight * 0.3)),
            // 右下卡片
            CardPosition(index: 2, name: positions[2], 
                        offset: CGPoint(x: (cardSize.width + spacing) * 0.5, y: triangleHeight * 0.3))
        ]
    }
    
    private func pentagramLayout(cardSize: CGSize, layoutBounds: CGSize) -> [CardPosition] {
        let diameter = min(layoutBounds.width, layoutBounds.height)
        let radius: CGFloat = diameter * 0.32  // 确保卡片不超出边界
        var cardPositions: [CardPosition] = []
        
        for i in 0..<5 {
            let angle = Double(i) * 2 * .pi / 5 - .pi / 2  // 从顶部开始
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            cardPositions.append(CardPosition(
                index: i, 
                name: self.positions[i], 
                offset: CGPoint(x: x, y: y),
                rotation: 0  // 五角星卡片保持垂直
            ))
        }
        return cardPositions
    }
    
    private func celticCrossLayout(cardSize: CGSize, layoutBounds: CGSize) -> [CardPosition] {
        let spacingX: CGFloat = cardSize.width * 0.15
        let spacingY: CGFloat = cardSize.height * 0.2
        let totalWidth = cardSize.width * 5 + spacingX * 4
        let totalHeight = cardSize.height * 2 + spacingY
        
        // 确保布局居中
        let startX = -totalWidth * 0.5 + cardSize.width * 0.5
        let startY = -totalHeight * 0.5 + cardSize.height * 0.5
        
        var cardPositions: [CardPosition] = []
        
        // 2排，每排5张
        for row in 0..<2 {
            for col in 0..<5 {
                let index = row * 5 + col
                let x = startX + CGFloat(col) * (cardSize.width + spacingX)
                let y = startY + CGFloat(row) * (cardSize.height + spacingY)
                cardPositions.append(CardPosition(
                    index: index, 
                    name: positions[index], 
                    offset: CGPoint(x: x, y: y)
                ))
            }
        }
        return cardPositions
    }
    
    private func yearlyLayout(cardSize: CGSize, layoutBounds: CGSize) -> [CardPosition] {
        let spacingX: CGFloat = cardSize.width * 0.12
        let spacingY: CGFloat = cardSize.height * 0.15
        let totalWidth = cardSize.width * 4 + spacingX * 3
        let totalHeight = cardSize.height * 3 + spacingY * 2
        
        // 确保布局居中
        let startX = -totalWidth * 0.5 + cardSize.width * 0.5
        let startY = -totalHeight * 0.5 + cardSize.height * 0.5
        
        var cardPositions: [CardPosition] = []
        
        // 3排，每排4张
        for row in 0..<3 {
            for col in 0..<4 {
                let index = row * 4 + col
                let x = startX + CGFloat(col) * (cardSize.width + spacingX)
                let y = startY + CGFloat(row) * (cardSize.height + spacingY)
                cardPositions.append(CardPosition(
                    index: index, 
                    name: self.positions[index], 
                    offset: CGPoint(x: x, y: y)
                ))
            }
        }
        return cardPositions
    }
}
