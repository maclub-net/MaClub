import Foundation

class TowerOfFantasyFixService {
    private let shellService = ShellService.shared
    private let bundleIdentifier = "com.pwrd.huanta"
    
    func fixCharacterRendering() async -> (success: Bool, output: String, error: String) {
        let executable = "~/Library/Containers/io.playcover.PlayCover/Applications/com.pwrd.huanta.app/QRSL"
        let expandedPath = await shellService.expandPath(executable)
        
        let exists = await shellService.checkFileExists(at: expandedPath)
        guard exists else {
            return (false, "", "未找到QRSL文件，请确认幻塔已通过Mac俱乐部客户端安装")
        }
        
        let otoolResult = await shellService.execute(command: "otool -Iv '\(expandedPath)'")
        guard otoolResult.isSuccess else {
            return (false, "", "otool 执行失败: \(otoolResult.error)")
        }
        
        let funcAddr = parseOtoolOutput(otoolResult.output)
        
        guard let addr = funcAddr else {
            let error = """
无法定位目标函数地址

可能的原因：
1. 游戏版本已更新，补丁不再适用
2. 补丁已经被应用过
"""
            return (false, "", error)
        }
        
        let adjustedAddr = addr - 0x100000000
        let ddResult = await shellService.execute(command: "printf '\\x20\\x00\\xC0\\xD2\\xC0\\x03\\x5F\\xD6' | dd of='\(expandedPath)' bs=1 seek=\(adjustedAddr) conv=notrunc")
        
        guard ddResult.isSuccess else {
            return (false, "", "补丁应用失败: \(ddResult.error)")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(expandedPath)' --deep --preserve-metadata=entitlements")
        
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        if codesignResult.isSuccess {
            let output = """
角色建模渲染修复完成！

已执行的操作：
1. 定位 QRSL 中的 _os_proc_available_memory 函数地址
2. 写入修正指令
3. 重新签名框架

请重新启动Mac俱乐部客户端并启动游戏测试。
"""
            return (true, output, filteredError)
        }
        
        return (false, codesignResult.output, filteredError)
    }
    
    private func parseOtoolOutput(_ output: String) -> Int? {
        for line in output.components(separatedBy: "\n") {
            if line.contains("_os_proc_available_memory") {
                let parts = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                if let firstPart = parts.first,
                   let addr = Int(firstPart, radix: 16) {
                    return addr
                }
            }
        }
        
        return nil
    }
}
