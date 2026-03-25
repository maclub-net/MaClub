import Foundation

class RockKingdomAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01KMCQ82MNTZPNNB3RA2DED868",
            name: "洛克王国：世界",
            bundleIdentifier: "com.tencent.nrc",
            description: "腾讯魔方工作室群自研的开放世界精灵捕捉游戏",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "rockkingdom_init_fix",
                name: "修复初始化失败",
                description: "修复游戏启动时提示\"初始化失败\"的问题",
                detailedDescription: """
游戏启动时可能会提示"初始化失败"，这是由于游戏容器目录下的 Documents 目录结构异常导致的。

此工具会：
1. 删除异常的 Documents 目录结构
2. 创建正确的符号链接

执行的操作：
rm -rf /Users/$USER/Library/Containers/com.tencent.nrc/Data/Documents/Users/$USER/Library/Containers/com.tencent.nrc/Data
ln -sf /Users/$USER/Library/Containers/com.tencent.nrc/Data /Users/$USER/Library/Containers/com.tencent.nrc/Data/Documents/Users/$USER/Library/Containers/com.tencent.nrc/Data
""",
                icon: "arrow.clockwise",
                category: .crash,
                fixAction: .shellCommand("""
                    rm -rf /Users/$USER/Library/Containers/com.tencent.nrc/Data/Documents/Users/$USER/Library/Containers/com.tencent.nrc/Data && \
                    ln -sf /Users/$USER/Library/Containers/com.tencent.nrc/Data /Users/$USER/Library/Containers/com.tencent.nrc/Data/Documents/Users/$USER/Library/Containers/com.tencent.nrc/Data
                    """)
            )
        ]
    }
}
