//
//  MainView.swift
//  PlayCover
//

import SwiftUI

struct MainView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controlActiveState) var controlActiveState

    @EnvironmentObject var apps: AppsVM
    @EnvironmentObject var store: StoreVM
    @EnvironmentObject var integrity: AppIntegrity

    @ObservedObject var keyCoverObserved = KeyCoverObservable.shared

    @Binding public var isSigningSetupShown: Bool

    @State private var selectedView: Int? = -1
    @State private var navWidth: CGFloat = 0
    @State private var viewWidth: CGFloat = 0
    @State private var collapsed: Bool = false
    @State private var showSourceFolders = true
    @State private var selectedBackgroundColor: Color = Color.accentColor
    @State private var selectedTextColor: Color = Color.black

    @State private var showMaclubLoginSheet = false
    @State private var showMaclubUserProfile = false
    @StateObject private var maclubAuthService = AuthService.shared

    @ObservedObject private var URLObserved = URLObservable.shared

    var body: some View {
        GeometryReader { viewGeom in
            NavigationView {
                GeometryReader { sidebarGeom in
                    VStack(spacing: 0) {
                        List {
                            NavigationLink(tag: 1, selection: $selectedView) {
                                MaclubHomeView()
                            } label: {
                                Label("应用商店", systemImage: "magnifyingglass")
                            }
                            NavigationLink(tag: 2, selection: $selectedView) {
                                AppLibraryView(selectedBackgroundColor: $selectedBackgroundColor,
                                                                           selectedTextColor: $selectedTextColor)
                            } label: {
                                Label("sidebar.appLibrary", systemImage: "square.grid.2x2")
                            }
                            NavigationLink(tag: 101, selection: $selectedView) {
                                MaclubToolLibraryView()
                            } label: {
                                Label("工具库", systemImage: "wrench.and.screwdriver")
                            }
                            NavigationLink(tag: 102, selection: $selectedView) {
                                MaclubDownloadManagerView()
                            } label: {
                                Label("下载管理", systemImage: "arrow.down.circle")
                            }
                        }

                        Divider()

                        MaclubUserStatusView(
                            authService: maclubAuthService,
                            showLoginSheet: $showMaclubLoginSheet,
                            showUserProfile: $showMaclubUserProfile
                        )
                    }
                    .toolbar {
                        ToolbarItem {
                            Button {
                                toggleSidebar()
                            } label: {
                                Image(systemName: "sidebar.leading")
                            }
                        }
                    }
                    .onChange(of: sidebarGeom.size) { newSize in
                        navWidth = newSize.width
                    }
                    .onChange(of: colorScheme) { scheme in
                        if scheme == .dark {
                            selectedTextColor = .white
                        } else {
                            if controlActiveState == .inactive {
                                selectedTextColor = .black
                            } else {
                                selectedTextColor = .white
                            }
                        }
                    }
                    .onChange(of: controlActiveState) { state in
                        if state == .inactive {
                            if colorScheme == .light {
                                selectedTextColor = .black
                            }
                            selectedBackgroundColor = .secondary
                        } else {
                            if colorScheme == .light {
                                selectedTextColor = .white
                            }
                            selectedBackgroundColor = .accentColor
                        }
                    }
                    .onAppear {
                        if colorScheme == .dark {
                            selectedTextColor = .white
                        } else {
                            if controlActiveState == .inactive {
                                selectedTextColor = .black
                            } else {
                                selectedTextColor = .white
                            }
                        }
                    }
                }
                .background(SplitViewAccessor(sideCollapsed: $collapsed))
            }
            .onAppear {
                self.selectedView = URLObserved.type == .source ? 2 : 1
            }
            .overlay {
                HStack {
                    if !collapsed {
                        Spacer()
                            .frame(width: navWidth)
                    }
                    ToastView()
                        .environmentObject(ToastVM.shared)
                        .environmentObject(InstallVM.shared)
                        .environmentObject(DownloadVM.shared)
                        .frame(width: collapsed || viewWidth < navWidth ? viewWidth : (viewWidth - navWidth))
                        .animation(.spring(), value: collapsed)
                }
            }
            .onChange(of: viewGeom.size) { newSize in
                viewWidth = newSize.width
            }
            .alert("alert.moveAppToApplications.title",
                   isPresented: $integrity.integrityOff) {
                Button("alert.moveAppToApplications.move", role: .cancel) {
                    integrity.moveToApps()
                }
                .tint(.accentColor)
                .keyboardShortcut(.defaultAction)
            } message: {
                Text("alert.moveAppToApplications.subtitle")
            }
            .sheet(isPresented: $isSigningSetupShown) {
                SignSetupView(isSigningSetupShown: $isSigningSetupShown)
            }
            .onChange(of: URLObserved.action) { _ in
                self.selectedView = URLObserved.type == .source ? 2 : self.selectedView
            }
            .sheet(isPresented: $keyCoverObserved.isKeyCoverUnlockingPromptShown) {
                KeyCoverUnlockingPrompt()
            }
            .sheet(isPresented: $showMaclubLoginSheet) {
                MaclubLoginView()
            }
            .sheet(isPresented: $showMaclubUserProfile) {
                MaclubUserProfileView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .showLoginSheet)) { _ in
                showMaclubLoginSheet = true
            }
        }
        .frame(minWidth: 675, minHeight: 330)
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct SplitViewAccessor: NSViewRepresentable {
    @Binding var sideCollapsed: Bool

    func makeNSView(context: Context) -> some NSView {
        let view = MyView()
        view.sideCollapsed = _sideCollapsed
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {}

    class MyView: NSView {
        var sideCollapsed: Binding<Bool>?
        weak private var controller: NSSplitViewController?
        private var observer: Any?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            var sview = superview

            // Find split view through hierarchy
            // swiftlint:disable:next force_unwrapping
            while sview != nil, !sview!.isKind(of: NSSplitView.self) {
                sview = sview?.superview
            }
            guard let sview = sview as? NSSplitView else { return }

            controller = sview.delegate as? NSSplitViewController

            if let sideBar = controller?.splitViewItems.first {
                observer = sideBar.observe(\.isCollapsed, options: [.new]) { [weak self] _, change in
                    if let value = change.newValue {
                        self?.sideCollapsed?.wrappedValue = value
                    }
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    @State static var isSigningSetupShown = true

    static var previews: some View {
        MainView(isSigningSetupShown: $isSigningSetupShown)
            .environmentObject(InstallVM.shared)
            .environmentObject(AppsVM.shared)
            .environmentObject(StoreVM.shared)
            .environmentObject(AppIntegrity())
    }
}
