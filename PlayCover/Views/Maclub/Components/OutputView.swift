import SwiftUI

struct OutputView: View {
    let output: String
    let error: String
    let isSuccess: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(isSuccess ? .green : .orange)
                
                Text(isSuccess ? "执行成功" : "执行结果")
                    .font(.headline)
                
                Spacer()
            }
            
            if !output.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("输出:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ScrollView {
                        Text(output)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(nsColor: .textBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .frame(maxHeight: 150)
                }
            }
            
            if !error.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("错误信息:")
                        .font(.caption)
                        .foregroundStyle(.red)
                    
                    ScrollView {
                        Text(error)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .frame(maxHeight: 100)
                }
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
