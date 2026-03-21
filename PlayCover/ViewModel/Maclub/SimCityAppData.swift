import Foundation

class SimCityAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01JWJJ9ZGV42F8KE6243AHAM6R",
            name: "SimCity (美区)",
            bundleIdentifier: "com.ea.simcitymobile.bv",
            logoName: "simcity",
            description: "经典城市建造模拟游戏（美区版本）",
            tools: tools,
            downloadURL: URL(string: "https://www.maclub.net/appstore/01JWJJ9ZGV42F8KE6243AHAM6R")
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "simcity_crash",
                name: "闪退修复",
                description: "修复美区版SimCity的anzu.sdk.framework平台兼容性问题",
                detailedDescription: """
美区版SimCity在PlayCover运行时可能因为anzu.sdk.framework的平台声明问题而闪退。

此工具通过以下步骤修复：
1. 备份原始anzu.sdk文件
2. 移除iOS平台声明
3. 设置macCatalyst平台声明
4. 重新签名框架和应用

修复后请重启PlayCover并启动游戏测试。

注意：此修复仅适用于美区版本（com.ea.simcitymobile.bv），国区版本不需要此修复。

如需恢复原始文件，备份文件保存在原文件同目录下，后缀为.backup。
""",
                icon: "exclamationmark.triangle.fill",
                category: .crash,
                fixAction: .custom("simcity_crash")
            )
        ]
    }
}
