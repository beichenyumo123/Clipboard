import SwiftUI

/// Displayed when the clipboard history is empty.
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clipboard")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: 4) {
                Text("剪贴板为空")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Text("复制一些内容，它会出现在这里")
                    .font(.system(size: 10))
                    .foregroundColor(.tertiaryLabel)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
