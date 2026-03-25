import Foundation

class AppDataManager {
    static let shared = AppDataManager()
    
    let apps: [FixApp]
    
    private init() {
        self.apps = Self.createApps()
    }
    
    private static func createApps() -> [FixApp] {
        return [
            JkchessAppData.createApp(),
            SimCityAppData.createApp(),
            FortniteAppData.createApp(),
            AzurLaneAppData.createApp(),
            RockKingdomAppData.createApp()
        ]
    }
}
