import Foundation

struct ShellResult {
    let output: String
    let error: String
    let exitCode: Int32
    
    var isSuccess: Bool {
        exitCode == 0
    }
}

class ShellService {
    static let shared = ShellService()
    
    private init() {}
    
    func execute(command: String) -> ShellResult {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(data: outputData, encoding: .utf8) ?? ""
            let error = String(data: errorData, encoding: .utf8) ?? ""
            
            return ShellResult(
                output: output.trimmingCharacters(in: .whitespacesAndNewlines),
                error: error.trimmingCharacters(in: .whitespacesAndNewlines),
                exitCode: task.terminationStatus
            )
        } catch {
            return ShellResult(
                output: "",
                error: error.localizedDescription,
                exitCode: -1
            )
        }
    }
    
    func execute(script: String) -> ShellResult {
        return execute(command: script)
    }
    
    func executeAsync(command: String) async -> ShellResult {
        return await withCheckedContinuation { continuation in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            task.arguments = ["-c", command]
            
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            task.standardOutput = outputPipe
            task.standardError = errorPipe
            
            do {
                try task.run()
                task.waitUntilExit()
                
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                let output = String(data: outputData, encoding: .utf8) ?? ""
                let error = String(data: errorData, encoding: .utf8) ?? ""
                
                continuation.resume(returning: ShellResult(
                    output: output.trimmingCharacters(in: .whitespacesAndNewlines),
                    error: error.trimmingCharacters(in: .whitespacesAndNewlines),
                    exitCode: task.terminationStatus
                ))
            } catch {
                continuation.resume(returning: ShellResult(
                    output: "",
                    error: error.localizedDescription,
                    exitCode: -1
                ))
            }
        }
    }
    
    func checkFileExists(at path: String) async -> Bool {
        let result = await executeAsync(command: "test -f '\(path)' && echo 'exists'")
        return result.output == "exists"
    }
    
    func expandPath(_ path: String) async -> String {
        let expandedPath = path.replacingOccurrences(of: "~", with: NSHomeDirectory())
        return expandedPath
    }
}
