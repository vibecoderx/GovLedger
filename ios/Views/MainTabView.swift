import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var navigation: NavigationViewModel

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
                .tag(TabSelection.dashboard)
            
            AgencyListView()
                .tabItem {
                    Label("Agencies", systemImage: "building.columns.fill")
                }
                .tag(TabSelection.agencies)
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "sparkle.magnifyingglass")
                }
                .tag(TabSelection.explore)
            
            CovidSpendingView() // New Tab
                .tabItem {
                    Label("COVID-19", systemImage: "syringe.fill")
                }
                .tag(TabSelection.covid19)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(TabSelection.search)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(SettingsViewModel())
        .environmentObject(FilterViewModel())
        .environmentObject(NavigationViewModel())
}
