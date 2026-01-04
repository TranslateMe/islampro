import SwiftUI

/// Detailed view for a single Dua (supplication)
/// Shows full Arabic text, transliteration, translation, and metadata
///
/// Features:
/// - Large, readable Arabic text
/// - Clear transliteration and translation
/// - Copy functionality
/// - Favorite/unfavorite
/// - Reference source
/// - Repetition guidance
struct DuaDetailView: View {

    // MARK: - Properties

    let dua: Dua

    // MARK: - State

    @StateObject private var duaManager = DuaManager.shared
    @Environment(\.dismiss) var dismiss

    // MARK: - Environment

    @Environment(\.themeBackground) private var themeBackground
    @Environment(\.themeSecondaryBackground) private var themeSecondaryBackground
    @Environment(\.themeTextPrimary) private var themeTextPrimary
    @Environment(\.themeTextSecondary) private var themeTextSecondary
    @Environment(\.themeColor) private var themeColor

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Category Badge
                    categoryBadge

                    // Arabic Text
                    arabicTextSection

                    // Transliteration
                    transliterationSection

                    Divider()
                        .background(themeTextPrimary.opacity(0.2))

                    // Translation
                    translationSection

                    // Repetition
                    if dua.repetition != nil {
                        repetitionSection
                    }

                    // Reference
                    referenceSection

                    // Action Buttons
                    actionButtons
                }
                .padding()
            }
            .background(themeBackground.ignoresSafeArea())
            .navigationTitle("Dua")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeColor)
                }
            }
        }
    }

    // MARK: - Category Badge

    @ViewBuilder
    private var categoryBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: dua.category.icon)
            Text(dua.category.displayName)
        }
        .font(.system(size: 14, weight: .medium, design: .rounded))
        .foregroundColor(themeColor)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(themeColor.opacity(0.15))
        )
    }

    // MARK: - Arabic Text Section

    @ViewBuilder
    private var arabicTextSection: some View {
        Text(dua.arabicText)
            .font(.system(size: 28, weight: .medium))
            .foregroundColor(themeTextPrimary)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeSecondaryBackground.opacity(0.5))
            )
    }

    // MARK: - Transliteration Section

    @ViewBuilder
    private var transliterationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transliteration")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(themeTextSecondary)
                .textCase(.uppercase)

            Text(dua.transliteration)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(themeTextPrimary.opacity(0.9))
                .italic()
        }
    }

    // MARK: - Translation Section

    @ViewBuilder
    private var translationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Translation")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(themeTextSecondary)
                .textCase(.uppercase)

            Text(dua.translation)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(themeTextPrimary)
        }
    }

    // MARK: - Repetition Section

    @ViewBuilder
    private var repetitionSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "repeat")
                .font(.system(size: 16))
                .foregroundColor(themeColor)

            Text("Recite \(dua.repetition!) time\(dua.repetition! > 1 ? "s" : "")")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(themeColor)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeColor.opacity(0.1))
        )
    }

    // MARK: - Reference Section

    @ViewBuilder
    private var referenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reference")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(themeTextSecondary)
                .textCase(.uppercase)

            Text(dua.reference)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(themeTextSecondary)
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Copy Button
            Button(action: {
                let fullText = "\(dua.arabicText)\n\n\(dua.transliteration)\n\n\(dua.translation)\n\nReference: \(dua.reference)"
                UIPasteboard.general.string = fullText
                HapticFeedback.success()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 16))
                    Text("Copy")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(themeColor.opacity(0.15))
                .foregroundColor(themeColor)
                .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())

            // Favorite Button
            Button(action: {
                duaManager.toggleFavorite(dua)
                HapticFeedback.light()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: duaManager.isFavorite(dua) ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                    Text(duaManager.isFavorite(dua) ? "Saved" : "Save")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(duaManager.isFavorite(dua) ? Color.red.opacity(0.15) : themeSecondaryBackground.opacity(0.5))
                .foregroundColor(duaManager.isFavorite(dua) ? .red : themeTextPrimary)
                .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

// MARK: - Preview

#Preview {
    DuaDetailView(
        dua: Dua(
            arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            transliteration: "Bismillahir-Rahmanir-Rahim",
            translation: "In the name of Allah, the Most Gracious, the Most Merciful",
            category: .general,
            reference: "Quran 1:1"
        )
    )
    .preferredColorScheme(.dark)
}
