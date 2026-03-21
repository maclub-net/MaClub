import Foundation

class FortniteFixService {
    private let shellService = ShellService.shared
    
    func fixEntitlementIssue() async -> (success: Bool, output: String, error: String) {
        let userHome = NSHomeDirectory()
        let entitlementsSource = "\(userHome)/Library/Containers/net.maclub.www/Entitlements/com.epicgames.FortniteGame.plist"
        let embeddedDest = "\(userHome)/Library/Containers/net.maclub.www/Applications/com.epicgames.FortniteGame.app/embedded.mobileprovision"
        
        let entitlementsExists = await shellService.checkFileExists(at: entitlementsSource)
        guard entitlementsExists else {
            return (false, "", "未找到entitlements文件：\(entitlementsSource)\n\n请确认Fortnite已通过PlayCover安装")
        }
        
        let appDir = (embeddedDest as NSString).deletingLastPathComponent
        let result = await shellService.execute(command: "test -d '\(appDir)' && echo 'exists'")
        guard result.output == "exists" else {
            return (false, "", "未找到应用目录：\(appDir)\n\n请确认Fortnite已通过PlayCover安装")
        }
        
        let cpResult = await shellService.execute(command: "cp '\(entitlementsSource)' '\(embeddedDest)'")
        guard cpResult.isSuccess else {
            return (false, "", "拷贝entitlements文件失败: \(cpResult.error)")
        }
        
        let output = "修复ISSUE-009完成！\n已将entitlements文件拷贝并重命名为embedded.mobileprovision\n\n请重启PlayCover并启动游戏测试。"
        return (cpResult.isSuccess, output, cpResult.error)
    }
    
    func fixMemoryIssue() async -> (success: Bool, output: String, error: String) {
        let userHome = NSHomeDirectory()
        let executable = "\(userHome)/Library/Containers/net.maclub.www/Applications/com.epicgames.FortniteGame.app/FortniteClient-IOS-Shipping"
        
        let executableExists = await shellService.checkFileExists(at: executable)
        guard executableExists else {
            return (false, "", "未找到可执行文件：\(executable)\n\n请确认Fortnite已通过PlayCover安装")
        }
        
        let otoolResult = await shellService.execute(command: "otool -Iv '\(executable)' | grep _os_proc_available_memory | head -n1 | awk '{print $1}'")
        guard otoolResult.isSuccess else {
            return (false, "", "获取函数地址失败: \(otoolResult.error)")
        }
        
        let funcAddrStr = otoolResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !funcAddrStr.isEmpty else {
            return (false, "", "未找到_os_proc_available_memory函数地址")
        }
        
        let cleanAddrStr = funcAddrStr.replacingOccurrences(of: "0x", with: "")
        guard let funcAddr = Int(cleanAddrStr, radix: 16) else {
            return (false, "", "无法将十六进制地址转换为整数: \(funcAddrStr)")
        }
        
        let seekOffset = funcAddr - 0x100000000
        let ddResult = await shellService.execute(command: "printf '\\x20\\x00\\xC0\\xD2\\xC0\\x03\\x5F\\xD6' | dd of='\(executable)' bs=1 seek=\(seekOffset) conv=notrunc 2>/dev/null")
        guard ddResult.isSuccess else {
            return (false, "", "修改_os_proc_available_memory函数失败: \(ddResult.error)")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(executable)' --deep --preserve-metadata=entitlements")
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        let output = "修复ISSUE-011完成！\n已修改_os_proc_available_memory函数，固定返回4GB可用内存\n\n请重启PlayCover并启动游戏测试。\n\nTip: 将指令中第一个字节\\x20改为\\x40，即可变为8GB"
        return (codesignResult.isSuccess, output, filteredError)
    }
    
    func fixFirstResponderIssue() async -> (success: Bool, output: String, error: String) {
        let userHome = NSHomeDirectory()
        let executable = "\(userHome)/Library/Containers/net.maclub.www/Applications/com.epicgames.FortniteGame.app/FortniteClient-IOS-Shipping"
        
        let executableExists = await shellService.checkFileExists(at: executable)
        guard executableExists else {
            return (false, "", "未找到可执行文件：\(executable)\n\n请确认Fortnite已通过PlayCover安装")
        }
        
        let perlCmd = """
        perl -e 'open F, "+<:raw", $ARGV[0] or die $!; local $/; my $d = <F>; \
        my $i = index($d, pack("H*", "0860039114FDDF08094C40F92A4542F9")); \
        exit 1 if $i < 0; seek F, $i - 0x6C, 0; print F pack("H*", "1F2003D5"); close F;' '\(executable)'
        """
        let perlResult = await shellService.execute(command: perlCmd)
        guard perlResult.isSuccess else {
            return (false, "", "修复becomeFirstResponder问题失败: \(perlResult.error)\n\nWarning: 【不稳定的指令】该指令可能在下版本失效，请留意下版本是否有更新指令")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(executable)' --deep --preserve-metadata=entitlements")
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        let output = "修复非主线程调用becomeFirstResponder问题完成！\n\n请重启PlayCover并启动游戏测试。\n\nWarning: 【不稳定的指令】该指令可能在下版本失效，请留意下版本是否有更新指令"
        return (codesignResult.isSuccess, output, filteredError)
    }
    
    func fixDownloadIssue() async -> (success: Bool, output: String, error: String) {
        let userHome = NSHomeDirectory()
        let dataPath = "\(userHome)/Library/Containers/com.epicgames.FortniteGame/Data"
        let symlinkPath = "\(dataPath)/Documents/Users/\(NSUserName())/Library/Containers/com.epicgames.FortniteGame/Data"
        
        let result = await shellService.execute(command: "test -d '\(dataPath)' && echo 'exists'")
        guard result.output == "exists" else {
            return (false, "", "未找到数据目录：\(dataPath)\n\n请确认Fortnite已通过PlayCover安装")
        }
        
        let rmResult = await shellService.execute(command: "rm -rf '\(symlinkPath)'")
        guard rmResult.isSuccess else {
            return (false, "", "删除旧符号链接失败: \(rmResult.error)")
        }
        
        let lnResult = await shellService.execute(command: "ln -sf '\(dataPath)' '\(symlinkPath)'")
        guard lnResult.isSuccess else {
            return (false, "", "创建符号链接失败: \(lnResult.error)")
        }
        
        let output = "修复ISSUE-001完成！\n已删除并重建数据目录符号链接\n\n请重启PlayCover并启动游戏测试。"
        return (lnResult.isSuccess, output, lnResult.error)
    }
    
    func fixMouseIssue() async -> (success: Bool, output: String, error: String) {
        let output = "鼠标点击异常解决方案：\n\n使用PlayCover Nightly版，右键游戏图标 - 设置 - 键盘映射设置，启用\"disableBuiltinMouse\"选项。\n\n此问题需要在PlayCover中手动配置，无需执行修复操作。"
        return (true, output, "")
    }
}
