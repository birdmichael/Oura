import SwiftUI

struct TarotReadingView: View {
    let reading: TarotReading
    let onRestart: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {

                VStack(spacing: 12) {
                    Text(reading.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(localized: LocalizationKeys.Reading.interpretation)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                }
                .padding(.top, 40)
                

                Text("你抽出的这些牌，我将按照经典的牌阵进行排列，为你揭示内心的智慧和指引。")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                

                LazyVStack(spacing: 25) {
                    ForEach(Array(reading.cardReadings.enumerated()), id: \.offset) { index, cardReading in
                        CardReadingRow(
                            index: index + 1,
                            cardReading: cardReading
                        )
                    }
                }
                .padding(.horizontal, 20)
                

                VStack(spacing: 20) {
                    Text(localized: LocalizationKeys.Reading.summary)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    
                    Text(reading.overallSummary)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .padding(.horizontal, 20)
                    
                    if !reading.advice.isEmpty {
                        VStack(spacing: 12) {
                            Text(localized: LocalizationKeys.Reading.advice)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                            
                            Text(reading.advice)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 20)
                

                Button(action: onRestart) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)
                        Text(localized: LocalizationKeys.Reading.restart)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.15, blue: 0.2),
                    Color(red: 0.2, green: 0.15, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

struct CardReadingRow: View {
    let index: Int
    let cardReading: CardReading
    
    var body: some View {
        VStack(spacing: 16) {

            HStack {
                Text("\(index). \(cardReading.position.name)：")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                
                Text(cardReading.card.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Spacer()
            }
            
            HStack(alignment: .top, spacing: 20) {

                VStack {
                    TarotCardView(
                        cardType: cardReading.card.cardType,
                        isRevealed: true,
                        size: CGSize(width: 100, height: 150)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                

                VStack(alignment: .leading, spacing: 8) {
                    Text(cardReading.interpretation)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            

            if index < 5 {
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {

    let sampleCards = [
        TarotCardModel(cardType: .majorArcana(.fool)),
        TarotCardModel(cardType: .majorArcana(.magician)),
        TarotCardModel(cardType: .majorArcana(.highPriestess))
    ]
    
    let sampleSpread = UniversalTarotSpread(spreadType: .threeCard)
    let sampleReading = ReadingGenerator.generateReading(for: sampleSpread, cards: sampleCards)
    
    TarotReadingView(reading: sampleReading) {
        print("Restart reading")
    }
}