import Foundation

class NikkeCNAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01JVYNCN4JS9KRB1ZJMC97FEPD",
            name: "胜利女神：新的希望",
            bundleIdentifier: "com.tencent.nikke",
            description: "胜利女神：新的希望（国服），由Shift Up开发的第三人称射击游戏",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "nikkecn_display_fix",
                name: "画面显示不全修复",
                description: "修复游戏画面显示不全的问题",
                detailedDescription: """
常见表现：
- 游戏画面只显示部分内容
- 屏幕方向或分辨率异常

原因分析：
UnityDefaultViewController 的 supportedInterfaceOrientations 方法返回了错误的方向值。

解决方法：
修改该方法使其返回正确的方向值。

执行的操作：
1. 定位 UnityFramework 中的 supportedInterfaceOrientations 函数地址
2. 写入修正指令
3. 重新签名框架

修复后请重新启动游戏测试。
""",
                icon: "display",
                category: .display,
                fixAction: .custom("nikkecn_display_fix")
            ),
            FixTool(
                id: "nikkecn_redeem_code_fix",
                name: "兑换码界面修复",
                description: "修复兑换码界面显示异常的问题",
                detailedDescription: """
常见表现：
- 兑换码界面显示异常
- 无法正常输入兑换码

原因分析：
MSDKPIXWKWebViewController 的 supportedInterfaceOrientations 方法返回了错误的方向值。

解决方法：
修改该方法使其返回正确的方向值。

执行的操作：
1. 定位 MSDKPIXWebView 中的 supportedInterfaceOrientations 函数地址
2. 写入修正指令
3. 重新签名框架

修复后请重新启动游戏测试。
""",
                icon: "display",
                category: .display,
                fixAction: .custom("nikkecn_redeem_code_fix")
            ),
            FixTool(
                id: "nikkecn_limit_motion",
                name: "CPU占用异常修复",
                description: "修复游戏CPU占用异常偏高的问题",
                detailedDescription: """
常见表现：
- 游戏运行时CPU占用过高
- 风扇噪音大，设备发热严重

原因分析：
游戏频繁请求运动传感器数据，导致CPU负载过高。

解决方法：
启用"limitMotionUpdateFrequency"选项，限制运动传感器的更新频率。

修复后请重新启动游戏测试。
""",
                icon: "gauge",
                category: .performance,
                fixAction: .custom("nikkecn_limit_motion")
            )
        ]
    }
}
