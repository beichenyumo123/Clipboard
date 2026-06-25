import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "clipboard")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.stickyTextTertiary.opacity(0.5))

            VStack(spacing: 6) {
                Text("剪贴板为空")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.stickyTextSecondary)
                Text("复制任何内容，它会出现在这里")
                    .font(.system(size: 11))
                    .foregroundColor(.stickyTextTertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
