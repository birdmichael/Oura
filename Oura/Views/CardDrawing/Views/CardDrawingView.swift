import SwiftUI

enum AppPhase {
    case preparation
    case breathing
    case connection
    case shuffling
    case cardSelection
    case completed
}

struct CardDrawingView: View {
    @StateObject private var store = CardDrawingStore()
    @State private var showingSpreadSelector = false
    @State private var showingMagnifiedCard = false
    @State private var currentAppPhase: AppPhase = .preparation
    
    var body: some View {
        ZStack {
            purpleGradientBackground
                .ignoresSafeArea()
            
            Group {
                switch currentAppPhase {
                case .preparation:
                    preparationPhaseView
                case .breathing:
                    BreathingView {
                        currentAppPhase = .connection
                        store.currentPhase = .connection
                    }
                case .connection:
                    ConnectionView {
                        currentAppPhase = .shuffling  
                        store.currentPhase = .shuffling
                    }
                case .shuffling:
                    shufflingPhaseView
                case .cardSelection:
                    cardSelectionPhaseView
                case .completed:
                    completedPhaseView
                }
            }
        }
        .sheet(isPresented: $showingMagnifiedCard) {
            magnifiedCardView
        }
        .sheet(isPresented: $showingSpreadSelector) {
            SpreadSelectorView { spreadType in
                store.switchToSpread(spreadType)
            }
        }
        .onChange(of: store.showingMagnifiedCard) {
            showingMagnifiedCard = store.showingMagnifiedCard
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
    
    private var purpleGradientBackground: some View {
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
    

    
    private var preparationPhaseView: some View {
        VStack(spacing: 0) {
            titleSection
            
            Spacer(minLength: 40)
            
            spreadInfoSection
            
            Spacer(minLength: 30)
            
            mysticalElementsSection
            
            Spacer(minLength: 40)
            
            startButtonSection
            
            Spacer(minLength: 60)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Text("Oura")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.orange)
            }
            
            VStack(spacing: 8) {
                Text(localized: LocalizationKeys.App.subtitle)
                    .font(.title3)
                    .foregroundStyle(Color.orange.opacity(0.9))
                    .fontWeight(.medium)
                
                Text(localized: LocalizationKeys.App.tagline)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    private var spreadInfoSection: some View {
        VStack(spacing: 24) {
            spreadInfoCard
        }
        .padding(.horizontal, 30)
    }
    
    private var spreadInfoCard: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .frame(height: 60)
            .overlay(
                spreadInfoContent
                    .padding(.horizontal, 20)
            )
    }
    
    private var spreadInfoContent: some View {
        HStack(spacing: 12) {
            Image(systemName: spreadIcon)
                .font(.title2)
                .foregroundStyle(.orange)
            
            Text(store.currentSpread.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button(LocalizationKeys.Spread.Button.change.localized) {
                showingSpreadSelector = true
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())
        }
    }
    
    private var startButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                currentAppPhase = .breathing
                store.currentPhase = .breathing
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title3)
                    
                    Text(localized: LocalizationKeys.Preparation.Button.start)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.title3)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                )
                .shadow(color: .orange.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .padding(.horizontal, 40)
            
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text(localized: LocalizationKeys.App.privacy)
                    .font(.caption)
            }
            .foregroundStyle(.white.opacity(0.5))
        }
    }
    
    private var mysticalElementsSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                mysticalSymbol("moon.stars.fill", LocalizationKeys.Mystical.intuition)
                mysticalSymbol("eye.fill", LocalizationKeys.Mystical.insight)
                mysticalSymbol("heart.fill", LocalizationKeys.Mystical.emotion)
            }
            
            Text(localized: LocalizationKeys.App.wisdom)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
    
    private func mysticalSymbol(_ systemName: String, _ titleKey: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 50, height: 50)
                
                Circle()
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    .frame(width: 50, height: 50)
                
                Image(systemName: systemName)
                    .font(.title3)
                    .foregroundStyle(.orange)
            }
            
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    private var cardPreviewSection: some View {
        let spreadType = (store.currentSpread as? UniversalTarotSpread)?.spreadType ?? .relationship
        let previewCount = min(spreadType.cardCount, 5)
        
        return HStack(spacing: -20) {
            ForEach(0..<previewCount, id: \.self) { index in
                TarotCardView(
                    cardType: .majorArcana(.fool),
                    isRevealed: false,
                    size: CGSize(width: 60, height: 90)
                )
                .rotationEffect(.degrees(Double(index - 2) * 5))
                .offset(y: CGFloat(abs(index - 2)) * -5)
                .zIndex(Double(previewCount - index))
            }
        }
    }
    
    private var spreadIcon: String {
        let spreadType = (store.currentSpread as? UniversalTarotSpread)?.spreadType ?? .relationship
        switch spreadType {
        case .single: return "diamond.fill"
        case .threeCard: return "triangle.fill"
        case .relationship: return "heart.fill"
        case .celticCross: return "cross.fill"
        case .yearlyReading: return "calendar.circle.fill"
        }
    }
    
    private var phaseIndicatorSection: some View {
        HStack(spacing: 8) {
                                    ForEach([AppPhase.preparation, .breathing, .connection, .shuffling, .cardSelection, .completed], id: \.self) { phase in
                HStack(spacing: 4) {
                    Circle()
                        .fill(phaseColor(for: phase))
                        .frame(width: 6, height: 6)
                    
                    Text(phaseTitle(for: phase))
                        .font(.caption2)
                        .foregroundStyle(phaseColor(for: phase))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    private func cardsContainerSection(in size: CGSize) -> some View {
        cardsSection(in: size)
            .frame(height: layoutHeight(for: size, spreadType: currentSpreadType))
    }
    
    private func cardsSection(in size: CGSize) -> some View {
        let spreadType = currentSpreadType
        let cardPositions = spreadType.cardPositions(in: size)
        
        return ZStack {
            ForEach(Array(cardPositions.enumerated()), id: \.offset) { index, cardPosition in
                if index < store.currentSpread.cards.count {
                    CardDrawingCardView(
                        card: store.currentSpread.cards[index],
                        position: store.currentSpread.positions[index],
                        isSelected: store.selectedCardIndex == index,
                        isNextCard: index == store.nextCardIndex,
                        canTap: store.canTapCard(at: index),
                        cardSize: spreadType.optimalCardSize(for: size.width * 0.8, layoutHeight: size.height * 0.35)
                    ) {
                        handleCardTap(at: index)
                    }
                    .offset(x: cardPosition.offset.x, y: cardPosition.offset.y)
                    .rotationEffect(.degrees(cardPosition.rotation))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cardPosition.offset)
                }
            }
        }
    }
    
    private var shufflingPhaseView: some View {
        ShufflingPhaseView { 
            currentAppPhase = .cardSelection
            store.currentPhase = .cardSelection
        }
    }
    
    private var cardSelectionPhaseView: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {

                HStack {
                    Button(action: {
                        currentAppPhase = .preparation
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text(localized: LocalizationKeys.CardSelection.Button.restart)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                

                VStack(spacing: 8) {
                    Text(localized: LocalizationKeys.CardSelection.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    let remaining = store.currentSpread.cards.count - store.revealedCount
                    Text(localized: LocalizationKeys.CardSelection.remaining, arguments: remaining)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                

                cardsContainerSection(in: geometry.size)
                
                Spacer()
                

                VStack {
                    Button(action: {
                        currentAppPhase = .completed
                    }) {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .teal.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 56)
                            .overlay(
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                    Text(localized: LocalizationKeys.CardSelection.Button.results)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundStyle(.white)
                            )
                    }
                    .opacity(store.revealedCount >= store.currentSpread.cards.count ? 1.0 : 0.0)
                    .disabled(store.revealedCount < store.currentSpread.cards.count)
                    .animation(.easeInOut(duration: 0.3), value: store.revealedCount >= store.currentSpread.cards.count)
                    .padding(.horizontal, 40)
                }
            }
        }
    }
    
    private var completedPhaseView: some View {
        Group {
            if let reading = store.tarotReading {
                TarotReadingView(reading: reading) {
                    store.resetReading()
                    currentAppPhase = .preparation
                }
            } else {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text(localized: LocalizationKeys.Reading.generating)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.top, 20)
                }
            }
        }
    }
    
    private var currentSpreadType: TarotSpreadType {
        (store.currentSpread as? UniversalTarotSpread)?.spreadType ?? .relationship
    }
    
    @ViewBuilder
    private func currentPhaseContent(in size: CGSize) -> some View {
        switch store.currentPhase {
        case .preparation:
            preparationPhaseContent(in: size)
        case .breathing, .connection, .shuffling:
            VStack(spacing: 20) {
                Text("请等待...")
                    .font(.title3)
                    .foregroundStyle(.white)
                cardsContainerSection(in: size)
            }
        case .cardSelection:
            cardSelectionPhaseContent(in: size)
        case .completed:
            completedPhaseContent(in: size)
        }
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
    

    
    private func preparationPhaseContent(in size: CGSize) -> some View {
        VStack(spacing: 30) {

            VStack(spacing: 16) {
                Text(localized: LocalizationKeys.Preparation.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                

                VStack(spacing: 12) {
                    Text(localized: LocalizationKeys.Preparation.calmMind)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    Text(localized: LocalizationKeys.Preparation.focusQuestion)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    Text(localized: LocalizationKeys.Preparation.startJourney)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(height: 120)
                .padding(.horizontal, 30)
            }
            
            cardsContainerSection(in: size)
        }
    }
    

    
    private func cardSelectionPhaseContent(in size: CGSize) -> some View {
        VStack(spacing: 20) {

            VStack(spacing: 16) {
                Text(localized: LocalizationKeys.CardSelection.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                

                VStack(spacing: 12) {
                    let remaining = store.currentSpread.cards.count - store.revealedCount
                    if remaining > 0 {
                        Text(localized: LocalizationKeys.CardSelection.remaining, arguments: remaining)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        Text(localized: LocalizationKeys.CardSelection.tapToReveal)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Text(localized: LocalizationKeys.CardSelection.cardWisdom)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    } else {
                        Text(localized: LocalizationKeys.CardSelection.allSelected)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)
                            .multilineTextAlignment(.center)
                        
                        Text(localized: LocalizationKeys.CardSelection.interpretationReady)
                            .font(.body)
                            .foregroundStyle(.green.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Text(localized: LocalizationKeys.CardSelection.viewResults)
                            .font(.caption)
                            .foregroundStyle(.green.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(height: 120)
                .padding(.horizontal, 30)
            }
            
            cardsContainerSection(in: size)
        }
    }
    
    private func completedPhaseContent(in size: CGSize) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("占卜完成")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text("点击任意已翻开的牌查看详情")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            cardsContainerSection(in: size)
        }
    }
    

    
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            mainActionButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .sheet(isPresented: $showingSpreadSelector) {
            SpreadSelectorView { spreadType in
                store.switchToSpread(spreadType)
            }
        }
    }
    
    private var mainActionButton: some View {
        Button(action: handleMainAction) {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: mainButtonColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 56)
                .overlay(
                    HStack(spacing: 8) {
                        if store.currentPhase == .preparation {
                            Image(systemName: "sparkles")
                                .font(.title3)
                        }
                        
                        Text(mainButtonTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!canPerformMainAction)
        .opacity(canPerformMainAction ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: store.currentPhase)
    }
    
    private var magnifiedCardView: some View {
        NavigationView {
            ZStack {
                purpleGradientBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if let selectedIndex = store.selectedCardIndex,
                       selectedIndex < store.currentSpread.cards.count {
                        let card = store.currentSpread.cards[selectedIndex]
                        let position = store.currentSpread.positions[selectedIndex]
                        
                        VStack(spacing: 20) {
                            Text(position.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            if let tarotCard = card as? TarotCardModel {
                                TarotCardView(
                                    cardType: tarotCard.cardType,
                                    isRevealed: card.isRevealed,
                                    size: CGSize(width: 200, height: 300)
                                )
                            }
                            
                            Text(card.name)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.orange)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        store.toggleCardMagnification()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
    

    
    private func handleCardTap(at index: Int) {
        switch store.currentPhase {
        case .cardSelection:
            if index == store.nextCardIndex {
                store.selectCard(at: index)
            } else if store.currentSpread.cards[index].isRevealed && index == store.selectedCardIndex {
                store.toggleCardMagnification()
            }
        case .completed:
            if store.currentSpread.cards[index].isRevealed {
                store.selectedCardIndex = index
                store.toggleCardMagnification()
            }
        default:
            break
        }
    }
    
    private func handleMainAction() {
        switch store.currentPhase {
        case .preparation:
            currentAppPhase = .breathing
            store.currentPhase = .breathing
        case .completed:
            store.resetReading()
            currentAppPhase = .preparation
        default:
            break
        }
    }
    

    
    private var mainButtonTitle: String {
        switch store.currentPhase {
        case .preparation:
            return "开始占卜"
        case .breathing:
            return "呼吸中..."
        case .connection:
            return "连接中..."
        case .shuffling:
            return "洗牌中..."
        case .cardSelection:
            return "选牌进行中"
        case .completed:
            return "重新开始"
        }
    }
    
    private var mainButtonColors: [Color] {
        switch store.currentPhase {
        case .preparation:
            return [.orange, .red.opacity(0.8)]
        case .breathing:
            return [.blue, .cyan.opacity(0.8)]
        case .connection:
            return [.blue, .cyan.opacity(0.8)]
        case .shuffling:
            return [.gray, .gray.opacity(0.8)]
        case .cardSelection:
            return [.purple, .blue.opacity(0.8)]
        case .completed:
            return [.green, .teal.opacity(0.8)]
        }
    }
    
    private var canPerformMainAction: Bool {
        switch store.currentPhase {
        case .preparation, .completed:
            return true
        case .breathing, .connection, .shuffling, .cardSelection:
            return false
        }
    }
    
    private func phaseColor(for phase: AppPhase) -> Color {
        if phase == store.currentPhase {
            return .orange
        } else {
            let phases: [AppPhase] = [.preparation, .breathing, .connection, .shuffling, .cardSelection, .completed]
            let currentIndex = phases.firstIndex(of: store.currentPhase) ?? 0
            let phaseIndex = phases.firstIndex(of: phase) ?? 0
            
            if phaseIndex < currentIndex {
                return .green
            } else {
                return .gray.opacity(0.5)
            }
        }
    }
    
    private func phaseTitle(for phase: AppPhase) -> String {
        switch phase {
        case .preparation:
            return "准备"
        case .breathing:
            return "呼吸"
        case .connection:
            return "连接"
        case .shuffling:
            return "洗牌"
        case .cardSelection:
            return "选牌"
        case .completed:
            return "完成"
        }
    }
}

#Preview {
    CardDrawingView()

    .environment(\.locale, .init(identifier: "en"))
}
