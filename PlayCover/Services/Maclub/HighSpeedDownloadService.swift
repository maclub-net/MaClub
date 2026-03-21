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
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        loadDownloadRecords()
        loadDefaultDownloadPath()
    }
    
    func getHighSpeedDownloadLinks(versionId: Int, appName: String = "", appVersion: String = "", appIcon: String? = nil) async {
        isLoading = true
        error = nil
        
        let urlString = "https://www.maclub.net/appstore/dl/\(versionId)/vip"
        
        guard let url = URL(string: urlString) else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                error = "Invalid response"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(HighSpeedDownloadResponse.self, from: data)
            
            if result.code == 200 {
                for link in result.data {
                    var record = DownloadRecord(
                        id: UUID(),
                        appName: appName,
                        appVersion: appVersion,
                        downloadUrl: link.url,
                        channel: link.channel,
                        appIcon: appIcon,
                        downloadPath: nil,
                        fileSize: 0,
                        downloadedSize: 0,
                        status: .pending,
                        startTime: Date(),
                        endTime: nil
                    )
                    downloadRecords.append(record)
                    saveDownloadRecords()
                }
            } else {
                error = result.message
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func startDownload(record: DownloadRecord) {
        guard let url = URL(string: record.downloadUrl) else { return }
        
        let task = session.downloadTask(with: url)
        task.taskDescription = record.id.uuidString
        task.resume()
        downloadTasks[record.id] = task
        updateDownloadStatus(recordId: record.id, status: .downloading)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let taskDescription = downloadTask.taskDescription, let recordId = UUID(uuidString: taskDescription) else { return }
        
        updateDownloadProgress(recordId: recordId, downloadedSize: totalBytesWritten, totalSize: totalBytesExpectedToWrite)
        calculateDownloadSpeed(recordId: recordId, bytesWritten: bytesWritten)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let taskDescription = downloadTask.taskDescription, let recordId = UUID(uuidString: taskDescription) else { return }
        guard let response = downloadTask.response as? HTTPURLResponse else {
            updateDownloadStatus(recordId: recordId, status: .failed)
            return
        }
        
        let fileName = response.suggestedFilename ?? "downloaded_file.ipa"
        let destinationUrl = URL(fileURLWithPath: defaultDownloadPath).appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                try FileManager.default.removeItem(at: destinationUrl)
            }
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            
            updateDownloadPath(recordId: recordId, path: destinationUrl.path)
            updateDownloadStatus(recordId: recordId, status: .completed)
            updateEndTime(recordId: recordId, time: Date())
            
            // 自动安装IPA文件
            installIPA(at: destinationUrl)
        } catch {
            updateDownloadStatus(recordId: recordId, status: .failed)
        }
        
        downloadTasks.removeValue(forKey: recordId)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let taskDescription = task.taskDescription, let recordId = UUID(uuidString: taskDescription) else { return }
        
        if error != nil {
            updateDownloadStatus(recordId: recordId, status: .failed)
            downloadTasks.removeValue(forKey: recordId)
        }
    }
    
    func pauseDownload(recordId: UUID) {
        if let task = downloadTasks[recordId] {
            task.cancel(byProducingResumeData: { [weak self] data in
                if let data = data {
                    UserDefaults.standard.set(data, forKey: "resumeData_\(recordId)")
                }
                self?.updateDownloadStatus(recordId: recordId, status: .paused)
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
            updateDownloadStatus(recordId: record.id, status: .downloading)
        } else {
            startDownload(record: record)
        }
    }
    
    func cancelDownload(recordId: UUID) {
        if let task = downloadTasks[recordId] {
            task.cancel()
            downloadTasks.removeValue(forKey: recordId)
        }
        updateDownloadStatus(recordId: recordId, status: .failed)
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
            if let installedUrl = installedUrl {
                print("IPA安装成功: \(installedUrl)")
                self?.showSuccessAlert(message: "应用安装成功")
            } else {
                print("IPA安装失败")
                self?.showErrorAlert(message: "应用安装失败")
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
