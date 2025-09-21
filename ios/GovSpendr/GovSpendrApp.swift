import SwiftUI

@main
struct GovSpendrApp: App {
    // These StateObjects are the single source of truth for shared data
    // across the entire app. They are created once here.
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var filterViewModel = FilterViewModel()
    @StateObject private var navigationViewModel = NavigationViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                // Inject all shared ViewModels into the environment so any
                // child view can access them.
                .environmentObject(settingsViewModel)
                .environmentObject(filterViewModel)
                .environmentObject(navigationViewModel)
        }
    }
}

