//
//  ContentView.swift
//  Cloutgrid
//
//  Created by Afthash on 15/3/2026.
//

import SwiftUI
import Combine

enum TabIdentifier {
    case home, search, post, jobs, profile
}

enum ProfileActions {
    case connectInstagram
    case connectYoutube
}

class DeepLinkManager: ObservableObject {
    @Published var profileAction: ProfileActions? = nil
}

struct ContentView: View {
    @Environment(AuthManager.self) private var auth
    
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    
    @State private var selectedTab: TabIdentifier = .home
    @State private var path = NavigationPath()
    @State private var notificationSheet: Bool = false
    @State private var toast = ToastManager.shared
    @State private var homeScrollY = ScrollPosition(edge: .top)
    
    private var currentTitle: String {
        switch selectedTab {
        case .home:
            return ""
        case .search:
            return "Connect"
        case .post:
            return "Create"
        case .jobs:
            return "Collaborate"
        case .profile:
            return "@\(auth.user?.profile.username ?? "")"
        }
    }
    
    @ViewBuilder
    private var currentToolbarButtons: some View {
        switch selectedTab {
        case .home:
            Button {
                notificationSheet = true
            } label: {
                Image(systemName: "bell")
            }

        case .profile:
            Button {
                path.append("settings")
            } label: {
                Image(systemName: "gear")
            }
        default:
            EmptyView()
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "cloutgrid" else {
            return
        }
        
        if url.host == "profile" {
            selectedTab = .profile
            
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                return
            }
            
            if let instagramStatus = queryItems.first(where: { $0.name == "instagram" })?.value {
                if instagramStatus == "connected" {
                    deepLinkManager.profileAction = .connectInstagram
                    return
                }
            }
            
            if let youtubeStatus = queryItems.first(where: { $0.name == "youtube" })?.value {
                if youtubeStatus == "connected" {
                    deepLinkManager.profileAction = .connectYoutube
                    return
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if auth.isAuth {
                NavigationStack(path: $path) {
                    TabView(selection: $selectedTab) {
                        HomeView(
                            selectedTab: $selectedTab,
                            homePath: $path,
                            notificationSheet: $notificationSheet,
                            scrollY: $homeScrollY
                        )
                            .tabItem {
                                Label("", systemImage: "house")
                            }
                            .tag(TabIdentifier.home)
                        
                        SearchView(selectedTab: $selectedTab, searchPath: $path)
                            .tabItem { Label("", systemImage: "magnifyingglass") }
                            .tag(TabIdentifier.search)
                        
                        CreateView(selectedTab: $selectedTab, createPath: $path)
                            .tabItem { Label("", systemImage: "plus.circle") }
                            .tag(TabIdentifier.post)
                        
                        JobView(jobPath: $path)
                            .tabItem { Label("", systemImage: "briefcase") }
                            .tag(TabIdentifier.jobs)
                        
                        ProfileView(profilePath: $path)
                            .tabItem { Label("", systemImage: "person.circle") }
                            .tag(TabIdentifier.profile)
                    }
                    .tint(Color.second)
                    .navigationTitle(currentTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            currentToolbarButtons
                        }
                        
                        if selectedTab == .home {
                            ToolbarItem(placement: .topBarLeading) {
                                Image("LogoClear")
                                    .resizable()
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        withAnimation {
                                            homeScrollY.scrollTo(edge: .top)
                                        }
                                    }
                            }
                        }
                        
                        if selectedTab == .profile {
                            ToolbarItem {
                                Button {
                                    path.append("edit")
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                            }
                        }
                    }
                    .navigationDestination(for: UserContainer.self) { user in
                        OtherProfile(
                            username: user.profile.username,
                            type: user.profile.userType,
                            path: $path
                        )
                    }
                    .navigationDestination(for: ImageAction.self) { action in
                        switch action {
                        case .raw(let image):
                            ImageSelect(image: image, path: $path)
                        case .cropped(let image):
                            PostCreate(
                                image: image,
                                path: $path,
                                selectedTab: $selectedTab
                            )
                        case .profile(let image):
                            ImageSelect(
                                image: image,
                                path: $path
                            )
                        }
                    }
                    .navigationDestination(for: String.self) { value in
                        if value == "collab" {
                            CollabCreate(path: $path, selectedTab: $selectedTab)
                        } else if value == "settings" {
                            Settings().navigationTitle("Settings")
                        } else if value == "edit" {
                            EditProfile(path: $path)
                        }
                    }
                    .navigationDestination(for: [QuestionModel].self) { questions in
                        Questions(path: $path, questions: questions)
                    }
                    .navigationDestination(
                        for: ApplicationModel.self,
                        destination: { application in
                            Answers(
                                path: $path,
                                creator: application.creator,
                                questions: application.job.questions,
                                answers: application.answers
                            )
                        }
                    )
                    .navigationDestination(for: PostModel.self) { post in
                        PostDetail(profilePost: post)
                    }
                }
            } else {
                LandingView()
            }
            
            if toast.show {
                ToastView(message: toast.message, isSuccess: toast.isSuccess)
                    .padding(.top, 20)
                    .zIndex(1)
            }
        }
        .animation(.spring(), value: toast.show)
        .onOpenURL { url in
            handleIncomingURL(url)
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
        .environment(HomeManager())
        .environment(ProfileManager())
        .environment(JobManager())
        .environment(SearchManager())
        .environmentObject(DeepLinkManager())
        .environment(IntegrationManager())
}

