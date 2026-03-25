import Foundation
import Combine

class HighSpeedDownloadService: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var downloadRecords: [DownloadRecord] = []
    @Published var defaultDownloadPath: String = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path ?? ""
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var downloadTasks: [UUID: URLSessionDownloadTask] = [:]
    private var session: URLSession!
    private var cancellables = Set<AnyCancellable>()
    private let api = MaclubBaseService.shared
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        loadDownloadRecords()
        loadDefaultDownloadPath()
    }
    
    func getHighSpeedDownloadLinks(versionId: Int) async -> [HighSpeedDownloadLink] {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        let urlString = "https://www.maclub.net/appstore/dl/\(versionId)/vip"
        
        do {
            let result: HighSpeedDownloadResponse = try await api.requestWithURL(
                urlString: urlString,
                method: "GET",
                requiresAuth: api.isAuthenticated
            )
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if result.code == 200 {
                return result.data
            } else {
                DispatchQueue.main.async {
                    self.error = result.message
                }
                return []
            }
        } catch {
            DispatchQueue.main.async {
                if let apiError = error as? MaclubAPIError {
                    self.error = apiError.errorDescription
                } else {
                    self.error = error.localizedDescription
                }
                self.isLoading = false
            }
            return []
        }
    }
    
    func startDownload(record: DownloadRecord) {
        guard let url = URL(string: record.downloadUrl) else { return }
        
        // 开始下载进度显示
        DownloadVM.shared.next(.downloading, 0.0, 0.7)
        
        let task = session.downloadTask(with: url)
        task.taskDescription = record.id.uuidString
        task.resume()
        downloadTasks[record.id] = task
        DispatchQueue.main.async {
            self.updateDownloadStatus(recordId: record.id, status: .downloading)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let taskDescription = downloadTask.taskDescription, let recordId = UUID(uuidString: taskDescription) else { return }
        
        DispatchQueue.main.async {
            self.updateDownloadProgress(recordId: recordId, downloadedSize: totalBytesWritten, totalSize: totalBytesExpectedToWrite)
            self.calculateDownloadSpeed(recordId: recordId, bytesWritten: bytesWritten)
            
            // 更新下载进度显示
            if totalBytesExpectedToWrite > 0 {
                let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
                DownloadVM.shared.progress = progress
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let taskDescription = downloadTask.taskDescription, let recordId = UUID(uuidString: taskDescription) else { return }
        guard let response = downloadTask.response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                self.updateDownloadStatus(recordId: recordId, status: .failed)
            }
            return
        }
        
        let fileName = response.suggestedFilename ?? "downloaded_file.ipa"
        let destinationUrl = URL(fileURLWithPath: defaultDownloadPath).appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                try FileManager.default.removeItem(at: destinationUrl)
            }
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            
            DispatchQueue.main.async {
                self.updateDownloadPath(recordId: recordId, path: destinationUrl.path)
                self.updateDownloadStatus(recordId: recordId, status: .completed)
                self.updateEndTime(recordId: recordId, time: Date())
                
                // 更新下载进度为完成状态
                DownloadVM.shared.next(.integrity, 0.7, 0.95)
                
                // 自动安装IPA文件
                self.installIPA(at: destinationUrl)
            }
        } catch {
            DispatchQueue.main.async {
                self.updateDownloadStatus(recordId: recordId, status: .failed)
                DownloadVM.shared.next(.failed, 0.95, 1.0)
            }
        }
        
        downloadTasks.removeValue(forKey: recordId)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let taskDescription = task.taskDescription, let recordId = UUID(uuidString: taskDescription) else { return }
        
        if error != nil {
            DispatchQueue.main.async {
                self.updateDownloadStatus(recordId: recordId, status: .failed)
                self.downloadTasks.removeValue(forKey: recordId)
                DownloadVM.shared.next(.failed, 0.95, 1.0)
            }
        }
    }
    
    func pauseDownload(recordId: UUID) {
        if let task = downloadTasks[recordId] {
            task.cancel(byProducingResumeData: { [weak self] data in
                if let data = data {
                    UserDefaults.standard.set(data, forKey: "resumeData_\(recordId)")
                }
                DispatchQueue.main.async {
                    self?.updateDownloadStatus(recordId: recordId, status: .paused)
                }
            })
            downloadTasks.removeValue(forKey: recordId)
        }
    }
    
    func resumeDownload(record: DownloadRecord) {
        guard URL(string: record.downloadUrl) != nil else { return }
        
        if let resumeData = UserDefaults.standard.data(forKey: "resumeData_\(record.id)") {
            let task = session.downloadTask(withResumeData: resumeData)
            task.taskDescription = record.id.uuidString
            task.resume()
            downloadTasks[record.id] = task
            DispatchQueue.main.async {
                self.updateDownloadStatus(recordId: record.id, status: .downloading)
            }
        } else {
            startDownload(record: record)
        }
    }
    
    func cancelDownload(recordId: UUID) {
        if let task = downloadTasks[recordId] {
            task.cancel()
            downloadTasks.removeValue(forKey: recordId)
        }
        DispatchQueue.main.async {
            self.updateDownloadStatus(recordId: recordId, status: .failed)
        }
    }
    
    func deleteRecord(recordId: UUID) {
        downloadTasks.removeValue(forKey: recordId)
        downloadRecords.removeAll { $0.id == recordId }
        saveDownloadRecords()
    }
    
    func deleteRecordAndFile(recordId: UUID) {
        if let record = downloadRecords.first(where: { $0.id == recordId }),
           let downloadPath = record.downloadPath {
            if FileManager.default.fileExists(atPath: downloadPath) {
                try? FileManager.default.removeItem(atPath: downloadPath)
            }
        }
        deleteRecord(recordId: recordId)
    }
    
    func deleteFile(recordId: UUID) {
        guard let record = downloadRecords.first(where: { $0.id == recordId }),
              let downloadPath = record.downloadPath else { return }
        
        do {
            if FileManager.default.fileExists(atPath: downloadPath) {
                try FileManager.default.removeItem(atPath: downloadPath)
                updateDownloadPath(recordId: recordId, path: nil)
            }
        } catch {
            print("Failed to delete file: \(error)")
        }
    }
    
    func setDefaultDownloadPath(path: String) {
        defaultDownloadPath = path
        UserDefaults.standard.set(path, forKey: "defaultDownloadPath")
    }
    
    private func updateDownloadStatus(recordId: UUID, status: DownloadRecord.DownloadStatus) {
        if let index = downloadRecords.firstIndex(where: { $0.id == recordId }) {
            downloadRecords[index].status = status
            saveDownloadRecords()
        }
    }
    
    private func updateDownloadProgress(recordId: UUID, downloadedSize: Int64, totalSize: Int64) {
        if let index = downloadRecords.firstIndex(where: { $0.id == recordId }) {
            downloadRecords[index].downloadedSize = downloadedSize
            if downloadRecords[index].fileSize == 0 {
                downloadRecords[index].fileSize = totalSize
            }
            saveDownloadRecords()
        }
    }
    
    private func calculateDownloadSpeed(recordId: UUID, bytesWritten: Int64) {
        if let index = downloadRecords.firstIndex(where: { $0.id == recordId }) {
            let currentTime = Date()
            if let lastTime = downloadRecords[index].lastUpdateTime {
                let timeInterval = currentTime.timeIntervalSince(lastTime)
                if timeInterval > 0 {
                    let speed = Double(bytesWritten) / timeInterval
                    downloadRecords[index].downloadSpeed = downloadRecords[index].downloadSpeed * 0.7 + speed * 0.3
                }
            }
            downloadRecords[index].lastUpdateTime = currentTime
        }
    }
    
    private func updateDownloadPath(recordId: UUID, path: String?) {
        if let index = downloadRecords.firstIndex(where: { $0.id == recordId }) {
            downloadRecords[index].downloadPath = path
            saveDownloadRecords()
        }
    }
    
    private func updateEndTime(recordId: UUID, time: Date) {
        if let index = downloadRecords.firstIndex(where: { $0.id == recordId }) {
            downloadRecords[index].endTime = time
            saveDownloadRecords()
        }
    }
    
    func saveDownloadRecords() {
        if let data = try? JSONEncoder().encode(downloadRecords) {
            UserDefaults.standard.set(data, forKey: "downloadRecords")
        }
    }
    
    func loadDownloadRecords() {
        if let data = UserDefaults.standard.data(forKey: "downloadRecords"),
           let records = try? JSONDecoder().decode([DownloadRecord].self, from: data) {
            downloadRecords = records
        }
    }
    
    private func loadDefaultDownloadPath() {
        if let path = UserDefaults.standard.string(forKey: "defaultDownloadPath") {
            defaultDownloadPath = path
        }
    }
    
    private func installIPA(at url: URL) {
        Installer.install(ipaUrl: url, export: false) { [weak self] installedUrl in
            DispatchQueue.main.async {
                if let installedUrl = installedUrl {
                    print("IPA安装成功: \(installedUrl)")
                    DownloadVM.shared.next(.finish, 0.95, 1.0)
                    self?.showSuccessAlert(message: "应用安装成功")
                } else {
                    print("IPA安装失败")
                    DownloadVM.shared.next(.failed, 0.95, 1.0)
                    self?.showErrorAlert(message: "应用安装失败")
                }
            }
        }
    }
    
    private func showSuccessAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
    
    private func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "安装失败"
        alert.informativeText = message
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}
