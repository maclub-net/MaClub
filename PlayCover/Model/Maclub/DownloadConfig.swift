import Foundation

struct DownloadLink: Codable {
    let provider: String
    let url: String
    let code: String
}

struct DownloadResponse: Codable {
    let code: Int
    let message: String
    let data: [DownloadLink]
}

struct NetDiskInfo {
    let name: String
    let domain: String
    let icon: String
    let type: String
    let tips: String
    let background: String
}

struct DownloadChannelInfo {
    let name: String
    let icon: String
}

struct DownloadConfig {
    static let baseURL = "https://www.maclub.net"
    
    static let netDisk: [String: NetDiskInfo] = [
        "baidu": NetDiskInfo(
            name: "百度网盘",
            domain: "baidu.com",
            icon: "\(baseURL)/assets/images/icons/Baidudrive_A.png",
            type: "web",
            tips: "",
            background: ""
        ),
        "189": NetDiskInfo(
            name: "天翼云盘",
            domain: "189.cn",
            icon: "\(baseURL)/assets/images/icons/189drive_A.png",
            type: "web",
            tips: "",
            background: ""
        ),
        "139": NetDiskInfo(
            name: "移动云盘",
            domain: "139.com",
            icon: "\(baseURL)/assets/images/icons/139drive_A.png",
            type: "web",
            tips: "",
            background: ""
        ),
        "123": NetDiskInfo(
            name: "123云盘",
            domain: "123pan.com",
            icon: "\(baseURL)/assets/images/icons/123Pan_A.png",
            type: "qrcode",
            tips: "注册即送2T永久空间 每日1G高速流量",
            background: ""
        ),
        "115": NetDiskInfo(
            name: "115网盘",
            domain: "115.com",
            icon: "\(baseURL)/assets/images/icons/115drive_A.png",
            type: "web",
            tips: "",
            background: ""
        ),
        "alipan": NetDiskInfo(
            name: "阿里云盘",
            domain: "alipan.com",
            icon: "\(baseURL)/assets/images/icons/Alidrive_A.png",
            type: "web",
            tips: "",
            background: ""
        ),
        "onedrive": NetDiskInfo(
            name: "OneDrive",
            domain: "sharepoint.com",
            icon: "\(baseURL)/assets/images/icons/Onedrive_B.png",
            type: "web",
            tips: "",
            background: ""
        ),
        "weiyun": NetDiskInfo(
            name: "腾讯微云",
            domain: "weiyun.com",
            icon: "\(baseURL)/assets/images/icons/Weiyun_A.png",
            type: "web",
            tips: "",
            background: ""
        ),
        "lanzou": NetDiskInfo(
            name: "蓝奏云盘",
            domain: "lanzou.com",
            icon: "\(baseURL)/assets/images/icons/Lanzouyun_A.png",
            type: "web",
            tips: "",
            background: ""
        ),
        "quark": NetDiskInfo(
            name: "夸克网盘",
            domain: "quark.cn",
            icon: "\(baseURL)/assets/images/icons/Quark_A.png",
            type: "qrcode",
            tips: "注册就送1T永久空间 大文件无损传输",
            background: "\(baseURL)/assets/images/background/quark_bg.jpg"
        ),
        "xunlei": NetDiskInfo(
            name: "迅雷云盘",
            domain: "xunlei.com",
            icon: "\(baseURL)/assets/images/icons/Xunlei_A.png",
            type: "qrcode",
            tips: "",
            background: ""
        ),
        "uc": NetDiskInfo(
            name: "UC网盘",
            domain: "uc.cn",
            icon: "\(baseURL)/assets/images/icons/Uc_A.png",
            type: "qrcode",
            tips: "下载不限速 扫码免费领取1T永久空间",
            background: "\(baseURL)/assets/images/background/uc_bg.jpg"
        ),
        "ctfile": NetDiskInfo(
            name: "城通网盘",
            domain: "ctfile.com",
            icon: "\(baseURL)/assets/images/icons/Ctfile_A.png",
            type: "web",
            tips: "除非有会员 不然不要选",
            background: ""
        )
    ]
    
    static let downloadChannel: [String: DownloadChannelInfo] = [
        "10000": DownloadChannelInfo(
            name: "电信下载",
            icon: "\(baseURL)/assets/images/icons/10000.png"
        ),
        "10086": DownloadChannelInfo(
            name: "移动下载",
            icon: "\(baseURL)/assets/images/icons/10086.png"
        ),
        "10010": DownloadChannelInfo(
            name: "联通下载",
            icon: "\(baseURL)/assets/images/icons/10010.png"
        ),
        "universal": DownloadChannelInfo(
            name: "通用下载",
            icon: "\(baseURL)/assets/images/icons/universal.png"
        ),
        "international": DownloadChannelInfo(
            name: "国际下载",
            icon: "\(baseURL)/assets/images/icons/international.png"
        )
    ]
}
