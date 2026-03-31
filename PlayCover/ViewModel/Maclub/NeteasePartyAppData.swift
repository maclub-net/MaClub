import Foundation

class NeteasePartyAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01J81NZCN1ZX2ZE32DZTPJDGXV",
            name: "蛋仔派对",
            bundleIdentifier: "com.netease.party",
            description: "网易自研潮玩题材的休闲竞技手游",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "danzai_crash_fix",
                name: "闪退修复工具",
                description: "修复蛋仔派对闪退问题",
                detailedDescription: """
修复蛋仔派对闪退问题。

执行的操作：
1. 对游戏可执行文件应用二进制补丁，修复私有路径访问问题
2. 重新签名应用

此工具通过修改二进制文件中的路径字符串，将私有路径替换为空字符串，解决闪退问题。
""",
                icon: "wrench.fill",
                category: .crash,
                fixAction: .custom("danzai_crash_fix")
            )
        ]
    }
}
