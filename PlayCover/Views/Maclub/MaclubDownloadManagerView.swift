import SwiftUI

struct MaclubDownloadManagerView: View {
    @StateObject private var downloadService = HighSpeedDownloadService()
    @State private var showPathPicker = false
    @State private var refreshTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Text("默认下载位置")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    TextField("", text: $downloadService.defaultDownloadPath)
                        .disabled(true)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                    
                    Button(action: {
                        showPathPicker = true
                    }) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            if downloadService.downloadRecords.isEmpty {
                emptyStateView
            } else {
                downloadRecordsList
            }
            
            Divider()
            
            bottomStatusBar
        }
        .navigationTitle("下载管理")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    downloadService.downloadRecords.removeAll()
                    downloadService.saveDownloadRecords()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .disabled(downloadService.downloadRecords.isEmpty)
            }
        }
        .sheet(isPresented: $showPathPicker) {
            PathPickerView(downloadService: downloadService)
        }
        .onAppear {
            startRefreshTimer()
        }
        .onDisappear {
            stopRefreshTimer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无下载记录")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            Text("在应用详情页点击高速下载即可开始下载")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var downloadRecordsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(downloadService.downloadRecords) { record in
                    DownloadRecordRow(record: record, downloadService: downloadService)
                }
            }
            .padding(20)
        }
    }
    
    private var bottomStatusBar: some View {
        HStack {
            Text("共 \(downloadService.downloadRecords.count) 条下载记录")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            let downloadingCount = downloadService.downloadRecords.filter { $0.status == .downloading }.count
            if downloadingCount > 0 {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("\(downloadingCount) 个任务下载中")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.windowBackgroundColor))
    }
    
    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                downloadService.loadDownloadRecords()
            }
        }
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}

struct PathPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var downloadService: HighSpeedDownloadService
    @State private var selectedPath: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("选择下载目录")
                .font(.system(size: 18, weight: .semibold))
            
            HStack(spacing: 12) {
                TextField("", text: $selectedPath)
                    .disabled(true)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                
                Button("浏览") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = true
                    panel.directoryURL = URL(fileURLWithPath: selectedPath.isEmpty ? downloadService.defaultDownloadPath : selectedPath)
                    
                    if panel.runModal() == .OK, let url = panel.url {
                        selectedPath = url.path
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            HStack(spacing: 12) {
                Button("取消") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("确定") {
                    if !selectedPath.isEmpty {
                        downloadService.setDefaultDownloadPath(path: selectedPath)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 500)
        .onAppear {
            selectedPath = downloadService.defaultDownloadPath
        }
    }
}

struct DownloadRecordRow: View {
    let record: DownloadRecord
    @ObservedObject var downloadService: HighSpeedDownloadService
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            if let iconUrl = record.appIcon, let url = URL(string: iconUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "app.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                }
                .frame(width: 64, height: 64)
                .cornerRadius(12)
            } else {
                Image(systemName: "app.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                    .frame(width: 64, height: 64)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(record.appName.isEmpty ? "未知应用" : record.appName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(getStatusText())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(getStatusColor())
                        .cornerRadius(4)
                }
                
                HStack(spacing: 12) {
                    Label(record.channelDisplayName, systemImage: "bolt.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if !record.appVersion.isEmpty {
                        Label(record.appVersion, systemImage: "number")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Label(record.formattedStartTime, systemImage: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatFileSize(record.fileSize))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if record.status == .downloading {
                    downloadProgressView
                }
                
                actionButtons
            }
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var downloadProgressView: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.controlBackgroundColor))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(record.progress), height: 6)
                }
            }
            .frame(height: 6)
            
            HStack {
                Text("\(Int(record.progress * 100))%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.blue)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(formatDownloadSpeed(record.downloadSpeed))
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(formatFileSize(record.downloadedSize)) / \(formatFileSize(record.fileSize))")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 8) {
            if record.status == .pending || record.status == .failed || record.status == .paused {
                Button(action: {
                    downloadService.startDownload(record: record)
                }) {
                    Label("开始下载", systemImage: "play.fill")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            } else if record.status == .downloading {
                Button(action: {
                    downloadService.pauseDownload(recordId: record.id)
                }) {
                    Label("暂停", systemImage: "pause.fill")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            
            if record.isCompleted, let downloadPath = record.downloadPath {
                Button(action: {
                    NSWorkspace.shared.selectFile(downloadPath, inFileViewerRootedAtPath: "")
                }) {
                    Label("在Finder中显示", systemImage: "folder.fill")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            Button(action: {
                showDeleteAlert = true
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
            .alert("删除下载记录", isPresented: $showDeleteAlert) {
                Button("只删除记录", role: .destructive) {
                    downloadService.deleteRecord(recordId: record.id)
                }
                
                if record.downloadPath != nil {
                    Button("删除记录和文件", role: .destructive) {
                        downloadService.deleteRecordAndFile(recordId: record.id)
                    }
                }
                
                Button("取消", role: .cancel) {}
            } message: {
                Text("请选择删除方式")
            }
        }
    }
    
    private func getStatusText() -> String {
        switch record.status {
        case .pending:
            return "等待中"
        case .downloading:
            return "下载中"
        case .completed:
            return "已完成"
        case .failed:
            return "失败"
        case .paused:
            return "已暂停"
        }
    }
    
    private func getStatusColor() -> Color {
        switch record.status {
        case .pending:
            return .orange
        case .downloading:
            return .blue
        case .completed:
            return .green
        case .failed:
            return .red
        case .paused:
            return .gray
        }
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func formatDownloadSpeed(_ speed: Double) -> String {
        if speed < 1024 {
            return String(format: "%.1f B/s", speed)
        } else if speed < 1024 * 1024 {
            return String(format: "%.1f KB/s", speed / 1024)
        } else {
            return String(format: "%.1f MB/s", speed / (1024 * 1024))
        }
    }
}
