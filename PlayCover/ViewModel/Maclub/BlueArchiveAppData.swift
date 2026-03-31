import Foundation

class BlueArchiveAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01JGJSM404B26N40FQ0MXZ3PHY",
            name: "蔚蓝档案",
            bundleIdentifier: "com.RoamingStar.BlueArchive",
            description: "蔚蓝档案，由NEXON Games开发的学园都市RPG",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "bluearchive_limit_motion",
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
                fixAction: .custom("bluearchive_limit_motion")
            )
        ]
    }
}
