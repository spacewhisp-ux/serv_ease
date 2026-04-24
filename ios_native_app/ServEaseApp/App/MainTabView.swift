import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var sessionVM: SessionViewModel
    @StateObject private var notificationsVM = NotificationsViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            FaqListScreen()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "questionmark.circle.fill" : "questionmark.circle")
                    Text("FAQs")
                }
                .tag(0)

            TicketListScreen()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "ticket.fill" : "ticket")
                    Text("Tickets")
                }
                .tag(1)

            NotificationsScreen()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "bell.fill" : "bell")
                    Text("Alerts")
                }
                .badge(notificationsVM.unreadCount > 0 ? (notificationsVM.unreadCount > 99 ? "99+" : "\(notificationsVM.unreadCount)") : nil)
                .tag(2)
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == 2 {
                Task { await notificationsVM.load() }
            }
        }
        .task {
            await notificationsVM.load()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if sessionVM.canManageFaqs {
                        NavigationLink {
                            AdminFaqManagementScreen()
                        } label: {
                            Label("FAQ management", systemImage: "list.bullet.clipboard")
                        }
                    }
                    NavigationLink {
                        SettingsScreen()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    Button(role: .destructive) {
                        Task { await sessionVM.logout() }
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}
