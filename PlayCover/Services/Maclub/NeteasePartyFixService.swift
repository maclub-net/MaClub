import Foundation

class NeteasePartyFixService {
    private let shellService = ShellService.shared
    
    func fixCrash() async -> (success: Bool, output: String, error: String) {
        let executablePath = "~/Library/Containers/io.playcover.PlayCover/Applications/com.netease.party.app/client"
        
        let expandedExecutablePath = await shellService.expandPath(executablePath)
        
        let fileExists = await shellService.checkFileExists(at: expandedExecutablePath)
        guard fileExists else {
            return (false, "", "未找到蛋仔派对可执行文件，请确认蛋仔派对已通过Mac俱乐部安装")
        }
        
        let backupPath = "\(expandedExecutablePath).backup"
        let backupResult = await shellService.execute(command: "cp '\(expandedExecutablePath)' '\(backupPath)'")
        guard backupResult.isSuccess else {
            return (false, "", "备份失败: \(backupResult.error)")
        }
        
        let perlCommand = """
        perl -e 'open F, "+<:raw", $ARGV[0] or die $!; \
        local $/; my $d = <F>; \
        my $i = index($d, "\\x00\\x2F\\x70\\x72\\x69\\x76\\x61\\x74\\x65\\x00"); \
        exit 1 if $i < 0; \
        seek F, $i, 0; \
        print F "\\x00\\x2F\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00"; \
        close F;' '\(expandedExecutablePath)'
        """
        
        let perlResult = await shellService.execute(command: perlCommand)
        guard perlResult.isSuccess else {
            return (false, "", "二进制补丁应用失败: \(perlResult.error)")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(expandedExecutablePath)' --deep --preserve-metadata=entitlements")
        
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        let output = "蛋仔派对闪退修复完成！\n备份文件位置: \(backupPath)\n\n请重启PlayCover并启动游戏测试。"
        return (codesignResult.isSuccess, output, filteredError)
    }
}
