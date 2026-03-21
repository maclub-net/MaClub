import Foundation

class AzurLaneAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01J3XJDVHV0W1Q6Q7QXXRQB29Y",
            name: "碧蓝航线",
            bundleIdentifier: "com.bilibili.azurlane",
            logoName: "azurlane",
            description: "bilibili出品的即时海战手游",
            tools: tools,
            downloadURL: URL(string: "https://www.maclub.net/appstore/01J3XJDVHV0W1Q6Q7QXXRQB29Y")
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "azurlane_key_mapping_issue",
                name: "按键映射失灵 ISSUE-014",
                description: "修复WASD和鼠标同时按下后按键映射失灵的问题",
                detailedDescription: """
常见表现：
- WASD和鼠标同时按下后，按键映射失灵
- 重启游戏后恢复正常

原因分析：
Unity的SessionProvider.init函数中存在某些问题，导致按键映射在特定情况下失灵。

解决方法：
在SessionProvider.init函数的两个特定位置写入NOP指令（0x1F2003D5），修复按键映射失灵问题。

执行的操作：
1. 定位UnityFramework中的SessionProvider.init函数地址
2. 在函数地址+0x1C4处写入NOP指令
3. 在函数地址+0x374处写入NOP指令
4. 重新签名框架
""",
                icon: "keyboard",
                category: .permission,
                fixAction: .custom("azurlane_key_mapping_issue")
            )
        ]
    }
}
