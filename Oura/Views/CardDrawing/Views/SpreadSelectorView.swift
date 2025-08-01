import SwiftUI

struct SpreadSelectorView: View {
    let onSpreadSelected: (TarotSpreadType) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(TarotSpreadType.allCases, id: \.self) { spreadType in
                        SpreadTypeCard(spreadType: spreadType) {
                            onSpreadSelected(spreadType)
                            dismiss()
                        }
                    }
                }
                .padding()
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
            .navigationTitle("选择牌阵")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

struct SpreadTypeCard: View {
    let spreadType: TarotSpreadType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 牌阵图标
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(height: 120)
                    
                    spreadIcon
                        .foregroundStyle(.white)
                        .font(.system(size: 40))
                }
                
                VStack(spacing: 4) {
                    Text(spreadType.localizedTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                    
                    Text(String.localizedStringWithFormat(NSLocalizedString("%lld张卡牌", value: "%lld张卡牌", comment: "Number of cards"), spreadType.cardCount))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(spreadType.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var spreadIcon: some View {
        switch spreadType {
        case .single:
            Image(systemName: "diamond.fill")
        case .threeCard:
            Image(systemName: "triangle.fill")
        case .relationship:
            Image(systemName: "star.fill")
        case .celticCross:
            Image(systemName: "cross.fill")
        case .yearlyReading:
            Image(systemName: "calendar.circle.fill")
        }
    }
}

#Preview {
    SpreadSelectorView { _ in }
}
