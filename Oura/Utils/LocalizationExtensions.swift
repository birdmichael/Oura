import SwiftUI
import Foundation

// MARK: - Localization Keys Extension
extension String {
    /// 获取本地化字符串
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// 获取带参数的本地化字符串
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Localization Keys Constants
enum LocalizationKeys {
    
    // MARK: - App Level
    enum App {
        static let title = "app.title"
        static let subtitle = "app.subtitle"
        static let tagline = "app.tagline"
        static let privacy = "app.privacy"
        static let wisdom = "app.wisdom"
    }
    
    enum Mystical {
        static let intuition = "mystical.intuition"
        static let insight = "mystical.insight"
        static let emotion = "mystical.emotion"
    }
    
    enum Breathing {
        static let title = "breathing.title"
        static let instruction = "breathing.instruction"
        static let remainingCycles = "breathing.remaining_cycles"
        static let focusMeditation = "breathing.focus_meditation"
        static let startPractice = "breathing.start_practice"
        static let followRhythm = "breathing.follow_rhythm"
        static let relaxBody = "breathing.relax_body"
        static let practiceComplete = "breathing.practice_complete"
        static let enteringConnection = "breathing.entering_connection"
        
        enum Button {
            static let start = "breathing.button.start"
            static let continueButton = "breathing.button.continue"
        }
        
        enum Status {
            static let inhale = "breathing.status.inhale"
            static let exhale = "breathing.status.exhale"
        }
    }
    
    enum Connection {
        static let title = "connection.title"
        static let instruction = "connection.instruction"
        static let energyText = "connection.energy_text"
        static let connectingCards = "connection.connecting_cards"
        static let feelEnergy = "connection.feel_energy"
        static let keepPressing = "connection.keep_pressing"
        static let longPressStart = "connection.long_press_start"
        
        enum Status {
            static let connecting = "connection.status.connecting"
            static let holdInstruction = "connection.status.hold_instruction"
            static let startInstruction = "connection.status.start_instruction"
            static let releaseWarning = "connection.status.release_warning"
        }
    }
    
    enum Shuffle {
        static let title = "shuffle.title"
        static let meditationTitle = "shuffle.meditation_title"
        static let thinkQuestion = "shuffle.think_question"
        static let energyFusion = "shuffle.energy_fusion"
        static let whenReady = "shuffle.when_ready"
        static let stayFocused = "shuffle.stay_focused"
        static let stopWhenReady = "shuffle.stop_when_ready"
        static let completed = "shuffle.completed"
        static let enterSelection = "shuffle.enter_selection"
        
        enum Instruction {
            static let start = "shuffle.instruction.start"
            static let stop = "shuffle.instruction.stop"
        }
        
        enum Button {
            static let start = "shuffle.button.start"
            static let stop = "shuffle.button.stop"
            static let continueButton = "shuffle.button.continue"
        }
    }
    
    enum CardSelection {
        static let title = "card_selection.title"
        static let remaining = "card_selection.remaining"
        static let tapToReveal = "card_selection.tap_to_reveal"
        static let cardWisdom = "card_selection.card_wisdom"
        static let allSelected = "card_selection.all_selected"
        static let interpretationReady = "card_selection.interpretation_ready"
        static let viewResults = "card_selection.view_results"
        
        enum Button {
            static let results = "card_selection.button.results"
            static let restart = "card_selection.button.restart"
        }
    }
    
    enum Completed {
        static let title = "completed.title"
        static let instruction = "completed.instruction"
    }
    
    enum Preparation {
        static let title = "preparation.title"
        static let calmMind = "preparation.calm_mind"
        static let focusQuestion = "preparation.focus_question"
        static let startJourney = "preparation.start_journey"
        
        enum Button {
            static let start = "preparation.button.start"
        }
    }
    
    // MARK: - Spread Types
    enum Spread {
        enum Button {
            static let change = "spread.button.change"
        }
        
        enum Single {
            static let title = "spread.single.title"
        }
        
        enum ThreeCard {
            static let title = "spread.three_card.title"
        }
        
        enum Relationship {
            static let title = "spread.relationship.title"
        }
        
        enum CelticCross {
            static let title = "spread.celtic_cross.title"
        }
        
        enum YearlyReading {
            static let title = "spread.yearly_reading.title"
        }
    }
    
    // MARK: - Common Elements
    enum Common {
        enum Button {
            static let cancel = "common.button.cancel"
            static let continueButton = "common.button.continue"
            static let close = "common.button.close"
        }
    }
    
    // MARK: - Status Messages
    enum Status {
        static let pleaseWait = "status.please_wait"
        static let readyToStart = "status.ready_to_start"
        static let completed = "status.completed"
    }
    
    enum Reading {
        static let interpretation = "reading.interpretation"
        static let summary = "reading.summary"
        static let advice = "reading.advice"
        static let generating = "reading.generating"
        static let restart = "reading.restart"
        
        enum Title {
            static let singleCard = "single_card_reading.title"
            static let threeCard = "three_card_reading.title"
            static let relationship = "relationship_reading.title"
            static let celticCross = "celtic_cross_reading.title"
            static let yearly = "yearly_reading.title"
        }
    }
}

// MARK: - SwiftUI Text Extension
extension Text {
    /// 创建本地化的 Text 视图
    init(localized key: String) {
        self.init(LocalizedStringKey(key))
    }
    
    /// 创建带参数的本地化 Text 视图
    init(localized key: String, arguments: CVarArg...) {
        let localizedString = String(format: NSLocalizedString(key, comment: ""), arguments: arguments)
        self.init(localizedString)
    }
}

// MARK: - Convenience Methods
extension LocalizationKeys {
    
    /// 获取牌阵标题的本地化字符串
    static func spreadTitle(for spreadType: TarotSpreadType) -> String {
        switch spreadType {
        case .single:
            return Spread.Single.title.localized
        case .threeCard:
            return Spread.ThreeCard.title.localized
        case .relationship:
            return Spread.Relationship.title.localized
        case .celticCross:
            return Spread.CelticCross.title.localized
        case .yearlyReading:
            return Spread.YearlyReading.title.localized
        }
    }
}