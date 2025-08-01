import SwiftUI

// 洗牌模块导出文件，便于其他模块导入和使用
public struct CardShuffleModule {
    public static func createView() -> some View {
        CardShuffleView()
    }
}

// 为了方便在ContentView中测试，创建一个简单的导航包装器
struct CardShuffleNavigationView: View {
    var body: some View {
        NavigationView {
            CardShuffleView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                }
        }
    }
}

#Preview {
    CardShuffleNavigationView()
}