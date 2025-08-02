import Foundation

// MARK: - 塔罗解读相关模型

/// 单张卡牌的解读信息
struct CardReading {
    let card: TarotCardModel
    let position: any TarotPosition
    let interpretation: String
}

/// 完整的塔罗解读
struct TarotReading {
    let spreadType: TarotSpreadType
    let cardReadings: [CardReading]
    let overallSummary: String
    let advice: String
    
    /// 解读标题
    var title: String {
        switch spreadType {
        case .single:
            return "single_card_reading.title".localized
        case .threeCard:
            return "three_card_reading.title".localized
        case .relationship:
            return "relationship_reading.title".localized
        case .celticCross:
            return "celtic_cross_reading.title".localized
        case .yearlyReading:
            return "yearly_reading.title".localized
        }
    }
}

/// 示例解读数据生成器
struct ReadingGenerator {
    
    /// 根据牌阵类型和选中的卡牌生成解读
    static func generateReading(for spread: any TarotSpread, cards: [TarotCardModel]) -> TarotReading {
        let cardReadings = zip(cards, spread.positions).map { card, position in
            CardReading(
                card: card,
                position: position,
                interpretation: generateInterpretation(for: card, in: position)
            )
        }
        
        let spreadType = (spread as? UniversalTarotSpread)?.spreadType ?? .relationship
        
        return TarotReading(
            spreadType: spreadType,
            cardReadings: cardReadings,
            overallSummary: generateOverallSummary(for: spreadType, cards: cards),
            advice: generateAdvice(for: spreadType)
        )
    }
    
    private static func generateInterpretation(for card: TarotCardModel, in position: any TarotPosition) -> String {
        // 这里可以根据卡牌和位置生成具体的解读
        // 暂时返回示例解读
        return generateSampleInterpretation(for: card, in: position)
    }
    
    private static func generateSampleInterpretation(for card: TarotCardModel, in position: any TarotPosition) -> String {
        let cardName = card.displayName
        let positionName = position.name
        
        // 根据位置生成不同的解读模板
        switch positionName {
        case "过去":
            return "\(cardName) 代表了你们关系最初的起点。这张牌暗示着过去的经历为现在的关系奠定了基础，带来了重要的影响和启示。"
        case "现在":
            return "\(cardName) 精准地描绘了你们关系的当前状态。它表明现在正是需要深入理解和接纳的时刻，这个阶段对关系的发展至关重要。"
        case "对方":
            return "\(cardName) 象征着对方对这段关系的内心感受。这张牌揭示了TA内心深处的想法和对这段关系的真实态度。"
        case "你":
            return "\(cardName) 代表了你对这段关系的内心状态。你的感受和期待在这张牌中得到了完美的体现。"
        case "未来":
            return "\(cardName) 为你们关系的未来带来了重要的指引。它预示着即将到来的变化和可能的发展方向。"
        default:
            return "\(cardName) 在\(positionName)位置上，为你带来了深刻的洞察和指引。"
        }
    }
    
    private static func generateOverallSummary(for spreadType: TarotSpreadType, cards: [TarotCardModel]) -> String {
        switch spreadType {
        case .relationship:
            return "这五张牌构成了一个完整的关系故事，从过去的基础，到现在的状态，再到你们各自的内心世界，最终指向未来的可能。每张牌都为这段关系的不同层面提供了深刻的洞察。"
        case .threeCard:
            return "这三张牌展现了时间的流动，从过去的经验，到现在的状况，再到未来的可能性。它们共同为你的问题提供了全面的指引。"
        default:
            return "这些卡牌为你的问题提供了深刻的洞察和指引，帮助你更好地理解当前的状况和未来的可能性。"
        }
    }
    
    private static func generateAdvice(for spreadType: TarotSpreadType) -> String {
        switch spreadType {
        case .relationship:
            return "建议你现在是'以退为进'的最佳时机。不要急着解决问题，而是要给自己和对方一些空间，用全新的眼光去看待彼此。当你和TA都能从内心深处理解并接纳对方，关系才能真正走向更高的境界。"
        case .threeCard:
            return "根据这三张牌的指引，建议你保持开放的心态，接受过去的经验，把握现在的机会，同时为未来做好准备。"
        default:
            return "请将这些洞察融入你的日常生活中，让塔罗的智慧指引你前行的道路。"
        }
    }
}