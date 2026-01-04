import SwiftUI

/// Main view for browsing Islamic supplications (Duas)
/// Features categorized browsing, search, and favorites
///
/// Design Philosophy:
/// - Clean, organized layout with categories
/// - Searchable collection
/// - Beautiful Arabic typography
/// - Easy access to detailed view
/// - Favorite/unfavorite functionality
/// - Adapts to all app themes
struct DuasView: View {

    // MARK: - State

    @StateObject private var duaManager = DuaManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: DuaCategory? = nil
    @State private var selectedDua: Dua? = nil
    @State private var isVisible = false

    // MARK: - Environment

    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeSecondaryBackground) private var themeSecondaryBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary
    @Environment(\.themeColor) private var themeColor

    // MARK: - Computed Properties

    private var filteredDuas: [Dua] {
        if !searchText.isEmpty {
            return duaManager.searchDuas(searchText)
        } else if let category = selectedCategory {
            return duaManager.getDuasByCategory(category)
        } else {
            return duaManager.duas
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                themeBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                        .padding()
                        .opacity(isVisible ? 1.0 : 0.0)

                    // Category Pills
                    if searchText.isEmpty {
                        categoryPills
                            .padding(.bottom, 8)
                            .opacity(isVisible ? 1.0 : 0.0)
                    }

                    // Duas List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(filteredDuas.enumerated()), id: \.element.id) { index, dua in
                                DuaCard(
                                    dua: dua,
                                    isFavorite: duaManager.isFavorite(dua),
                                    themeColor: themeColor,
                                    textColor: themeTextPrimary
                                ) {
                                    selectedDua = dua
                                } onFavorite: {
                                    duaManager.toggleFavorite(dua)
                                    HapticFeedback.light()
                                }
                                .staggeredEntrance(index: index)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Duas")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedDua) { dua in
                DuaDetailView(dua: dua)
            }
            .onAppear {
                withAnimation(AnimationUtilities.Spring.gentle) {
                    isVisible = true
                }
            }
        }
    }

    // MARK: - Search Bar

    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeTextSecondary)

            TextField("Search duas...", text: $searchText)
                .foregroundColor(themeTextPrimary)
        }
        .padding()
        .background(themeSecondaryBackground.opacity(0.5))
        .cornerRadius(12)
    }

    // MARK: - Category Pills

    @ViewBuilder
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryPill(
                    title: "All",
                    icon: "list.bullet",
                    isSelected: selectedCategory == nil,
                    themeColor: themeColor,
                    textColor: themeTextPrimary
                ) {
                    selectedCategory = nil
                    HapticFeedback.selection()
                }

                ForEach(DuaCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        themeColor: themeColor,
                        textColor: themeTextPrimary
                    ) {
                        selectedCategory = category
                        HapticFeedback.selection()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let themeColor: Color
    let textColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? themeColor : Color.gray.opacity(0.2))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Dua Card

struct DuaCard: View {
    let dua: Dua
    let isFavorite: Bool
    let themeColor: Color
    let textColor: Color
    let onTap: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: dua.category.icon)
                        .foregroundColor(themeColor)
                        .font(.system(size: 14))

                    Text(dua.category.displayName)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(textColor.opacity(0.7))

                    Spacer()

                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : textColor.opacity(0.5))
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Text(dua.arabicText)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(2)

                Text(dua.transliteration)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(textColor.opacity(0.8))
                    .italic()
                    .lineLimit(2)

                Text(dua.translation)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(textColor.opacity(0.6))
                    .lineLimit(2)

                if let repetition = dua.repetition {
                    Text("Repeat \(repetition)x")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(themeColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(themeColor.opacity(0.15))
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    DuasView()
        .preferredColorScheme(.dark)
}
