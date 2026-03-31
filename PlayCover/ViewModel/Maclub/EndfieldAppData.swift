import Foundation

class EndfieldAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01KFF8MWYVZ1AVJ4RNVNTT0621",
            name: "明日方舟：终末地",
            bundleIdentifier: "com.hypergryph.endfield",
            description: "鹰角网络开发的3D即时策略RPG游戏",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "endfield_block_sleep_spamming",
                name: "闪退修复",
                description: "修复游戏短暂运行后闪退的问题",
                detailedDescription: """
常见表现：
- 游戏启动后短暂运行即闪退
- 无法正常进入游戏

原因分析：
游戏可能频繁调用 usleep() 系统调用，导致资源耗尽而闪退。

解决方法：
启用"blockSleepSpamming"选项，阻止游戏频繁调用 usleep() 系统调用。

执行的操作：
1. 检查游戏是否已安装
2. 自动启用 blockSleepSpamming 选项
3. 保存应用设置

修复后请重新启动游戏测试。
""",
                icon: "exclamationmark.triangle.fill",
                category: .crash,
                fixAction: .custom("endfield_block_sleep_spamming")
            )
        ]
    }
}
