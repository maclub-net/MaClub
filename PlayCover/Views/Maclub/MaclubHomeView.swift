import SwiftUI

struct MaclubHomeView: View {
    @StateObject private var searchService = SearchService.shared
    @State private var isSearching = false
    @State private var hasSearched = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        Group {
            if !hasSearched && searchService.searchResults.isEmpty && !searchService.isLoading {
                homeSearchView
            } else {
                searchResultsView
            }
        }
        .navigationTitle("Mac俱乐部")
    }

    private var homeSearchView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                HStack(spacing: 24) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mac俱乐部")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.primary)

                        Text("是扩展Mac应用商店的神器")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                            .opacity(0.8)
                    }
                }
                .padding(.bottom, 20)

                searchField
            }
            .padding(.horizontal, 60)
            .padding(.bottom, 60)

            Spacer()

            VStack(spacing: 8) {
                Text("© 2024-2026 Mac俱乐部")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.6))

                Text("All Rights Reserved")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var searchResultsView: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 32) {
                searchField
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                if searchService.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("搜索中...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                } else if let error = searchService.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 60)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                        ForEach(searchService.searchResults) { app in
                            Button(action: {
                                AppDetailWindowManager.shared.openAppDetail(appId: app.id, title: app.appName)
                            }) {
                                SearchAppCard(app: app)
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(.secondary)

            TextField("搜索应用...", text: $searchService.searchText)
                .font(.system(size: 16))
                .onChange(of: searchService.searchText) { newValue in
                    searchTask?.cancel()

                    if newValue.isEmpty {
                        searchService.clearResults()
                        hasSearched = false
                        return
                    }

                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)

                        if !Task.isCancelled {
                            await performSearch()
                        }
                    }
                }
                .textFieldStyle(.plain)

            if !searchService.searchText.isEmpty {
                Button(action: {
                    searchService.searchText = ""
                    searchService.clearResults()
                    hasSearched = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: searchService.searchText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.textBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private func performSearch() async {
        guard !searchService.searchText.isEmpty else { return }
        hasSearched = true
        await searchService.search(keyword: searchService.searchText, perPage: 9)
    }
}

struct SearchAppCard: View {
    let app: SearchApp

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: app.appIcon)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 64, height: 64)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "app.dashed")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary.opacity(0.5))
                    @unknown default:
                        ProgressView()
                    }
                }
                .frame(width: 64, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(app.appName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(app.version)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))

                    HStack(spacing: 6) {
                        ForEach(app.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 11))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.1))
                                .cornerRadius(6)
                                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                        }
                    }
                }
            }

            Text(app.description)
                .font(.system(size: 13))
                .foregroundColor(.secondary.opacity(0.8))
                .lineLimit(2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.textBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
    }
}
