import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showSettingsGuide = false
    @State private var showVoiceInput = false
    @State private var selectedTheme: ThemeID = ThemeManager.shared.currentThemeID
    @State private var hapticsEnabled: Bool = ThemeManager.shared.hapticsEnabled
    @State private var soundEnabled: Bool = ThemeManager.shared.soundEnabled

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    voiceCTA
                    statusSection
                    themePickerSection
                    feedbackSection
                    setupGuideSection
                    footerSection
                }
                .padding()
            }
            .navigationTitle("Sweetkey")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettingsGuide = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showSettingsGuide) { SettingsGuideView() }
            .sheet(isPresented: $showVoiceInput) { VoiceInputView() }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "keyboard.fill").font(.system(size: 56)).foregroundStyle(.tint)
            Text("Sweetkey").font(.largeTitle.bold())
            Text("বাংলা ও ইংরেজি কাস্টম কিবোর্ড").font(.subheadline).foregroundStyle(.secondary)
        }.padding(.top, 12)
    }

    private var voiceCTA: some View {
        Button { showVoiceInput = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "mic.circle.fill").font(.system(size: 32))
                VStack(alignment: .leading, spacing: 2) {
                    Text("🎙️ ভয়েস দিয়ে টাইপ করুন").font(.headline)
                    Text("কথা বলুন — AI ঠিক করে কিবোর্ডে পাঠাবে").font(.caption).opacity(0.85)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding().frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)))
            .foregroundStyle(.white)
        }
    }

    private var statusSection: some View {
        HStack(spacing: 12) {
            Circle().fill(appState.fullAccessGranted ? Color.green : Color.orange)
                .frame(width: 12, height: 12)
            Text(appState.fullAccessGranted ? "Full Access চালু আছে" : "Full Access চালু নেই")
                .font(.subheadline.weight(.medium))
        }
        .padding().frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    private var themePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎨 থিম").font(.headline)
                Spacer()
                Text("কিবোর্ড বন্ধ করে আবার খুললে কার্যকর হবে").font(.caption2).foregroundStyle(.secondary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ThemeID.allCases, id: \.self) { themeID in
                        ThemeCard(themeID: themeID, isSelected: selectedTheme == themeID)
                            .onTapGesture {
                                selectedTheme = themeID
                                ThemeManager.shared.currentThemeID = themeID
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                    }
                }.padding(.horizontal, 2)
            }
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("✨ ফিডব্যাক").font(.headline)
            Toggle(isOn: $hapticsEnabled) {
                Label("হ্যাপটিক ভাইব্রেশন", systemImage: "iphone.radiowaves.left.and.right")
            }.onChange(of: hapticsEnabled) { ThemeManager.shared.hapticsEnabled = $0 }
            Toggle(isOn: $soundEnabled) {
                Label("ক্লিক সাউন্ড", systemImage: "speaker.wave.2.fill")
            }.onChange(of: soundEnabled) { ThemeManager.shared.soundEnabled = $0 }
        }
        .padding().background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var setupGuideSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("কিবোর্ড সেটআপ গাইড").font(.headline)
            ForEach(Array(setupSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)").font(.caption.bold())
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.accentColor.opacity(0.15)))
                    Text(step).font(.subheadline).fixedSize(horizontal: false, vertical: true)
                }
            }
        }.padding().background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var setupSteps: [String] {
        [
            "Settings → General → Keyboard → Keyboards → Add New Keyboard… চাপুন।",
            "তালিকা থেকে Sweetkey সিলেক্ট করুন।",
            "Sweetkey-এর উপর ট্যাপ করে \"Allow Full Access\" চালু করুন।",
            "যেকোনো টেক্সট ফিল্ডে গ্লোব আইকন চেপে Sweetkey সিলেক্ট করুন।",
            "🎙️ Voice বাটনে চাপলে Sweetkey অ্যাপ খুলবে — কথা বলুন, AI ঠিক করবে, কিবোর্ডে ফিরে টেক্সট বসবে।"
        ]
    }

    private var footerSection: some View {
        VStack(spacing: 4) {
            Text("Sweetkey v2.0.0").font(.caption).foregroundStyle(.secondary)
            Text("আপনার টাইপিং ও ভয়েস ডেটা ডিভাইসেই থাকে।").font(.caption2).foregroundStyle(.tertiary)
        }.padding(.vertical, 8)
    }
}

struct ThemeCard: View {
    let themeID: ThemeID
    let isSelected: Bool

    var body: some View {
        let theme = KeyboardTheme.theme(for: themeID)
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(Color(theme.background))
                    .frame(width: 100, height: 70)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3))
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        miniKey(theme.keyBackground, theme.keyText, "A")
                        miniKey(theme.keyBackground, theme.keyText, "B")
                        miniKey(theme.keyBackground, theme.keyText, "C")
                    }
                    HStack(spacing: 4) {
                        miniKey(theme.specialKeyBackground, theme.specialKeyText, "⌫")
                        miniKey(theme.keyBackground, theme.keyText, "space")
                    }
                }
            }
            Text(themeID.displayName)
                .font(.caption2.weight(isSelected ? .bold : .regular))
                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
        }
    }

    private func miniKey(_ bg: UIColor, _ text: UIColor, _ char: String) -> some View {
        Text(char).font(.system(size: 9, weight: .medium))
            .foregroundStyle(Color(text))
            .frame(width: 22, height: 16)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color(bg)))
    }
}

struct SettingsGuideView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("কিবোর্ড যোগ করুন") {
                    Text("Settings → General → Keyboard → Keyboards → Add New Keyboard… → Sweetkey")
                }
                Section("Allow Full Access") {
                    Text("Settings → General → Keyboard → Keyboards → Sweetkey → Allow Full Access চালু করুন।")
                    Text("এটি ছাড়া ক্লিপবোর্ড, AI ও ভয়েস ইনপুট কাজ করবে না।").font(.caption).foregroundStyle(.secondary)
                }
                Section("ভয়েস ইনপুট") {
                    Text("Settings → Sweetkey → Microphone ও Speech Recognition চালু করুন।")
                    Text("তারপর কিবোর্ডের 🎙️ বাটনে চাপুন।").font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("সেটিংস গাইড")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("সম্পন্ন") { dismiss() }
                }
            }
        }
    }
}
