import SwiftUI

struct VoiceInputView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var voice = VoiceInputManager()
    @State private var isFixingWithAI = false
    @State private var fixedText = ""
    @State private var savedConfirmation = false
    private let aiService = AIService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statusCard
                    transcriptCard
                    if !fixedText.isEmpty && fixedText != voice.transcript { fixedResultCard }
                    actionButtons
                    if savedConfirmation { savedBanner }
                }.padding()
            }
            .navigationTitle("🎙️ Voice Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("বন্ধ") { dismiss() }
                }
            }
            .task { await voice.requestPermissions() }
            .onDisappear { voice.stopRecording() }
        }
    }

    private var statusCard: some View {
        VStack(spacing: 12) {
            if voice.isRecording {
                HStack(spacing: 10) {
                    Circle().fill(Color.red).frame(width: 14, height: 14)
                    Text("শুনছি... কথা বলুন").font(.headline)
                }
            } else {
                Image(systemName: "mic.fill").font(.system(size: 44)).foregroundStyle(.tint)
                Text(voice.transcript.isEmpty ? "রেকর্ড করতে নিচের বাটন চাপুন" : "রেকর্ডিং সম্পন্ন")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            if let error = voice.errorMessage, !error.isEmpty {
                Text(error).font(.caption).foregroundStyle(.red).multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity).padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var transcriptCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Transcript").font(.headline)
                Spacer()
                if !voice.transcript.isEmpty {
                    Button { UIPasteboard.general.string = voice.transcript } label: {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
            Text(voice.transcript.isEmpty ? "—" : voice.transcript).font(.body)
                .frame(maxWidth: .infinity, alignment: .leading).padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.tertiarySystemBackground)))
        }
    }

    private var fixedResultCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("✨ AI-Fixed Text").font(.headline)
            Text(fixedText).font(.body)
                .frame(maxWidth: .infinity, alignment: .leading).padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor.opacity(0.12)))
        }
    }

    private var savedBanner: some View {
        Label("কিবোর্ডে পাঠানো হয়েছে — টেক্সট ফিল্ডে ফিরে গিয়ে দেখুন।", systemImage: "checkmark.circle.fill")
            .font(.subheadline).foregroundStyle(.green).padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.12)))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                if voice.isRecording { voice.stopRecording() }
                else { fixedText = ""; savedConfirmation = false; voice.startRecording() }
            } label: {
                Label(voice.isRecording ? "রেকর্ডিং বন্ধ" : "রেকর্ড শুরু",
                      systemImage: voice.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.headline).frame(maxWidth: .infinity).padding()
                    .background(voice.isRecording ? Color.red : Color.accentColor)
                    .foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12))
            }.disabled(voice.authStatus != .authorized)

            Button { fixWithAI() } label: {
                Label(isFixingWithAI ? "AI কাজ করছে…" : "✨ AI দিয়ে ঠিক করুন", systemImage: "sparkles")
                    .frame(maxWidth: .infinity).padding()
                    .background(Color(.secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 12))
            }.disabled(voice.transcript.isEmpty || isFixingWithAI)

            Button {
                let final = fixedText.isEmpty ? voice.transcript : fixedText
                guard !final.isEmpty else { return }
                SharedVoiceStore.savePendingVoiceText(final)
                UIPasteboard.general.string = final
                savedConfirmation = true
            } label: {
                Label("সংরক্ষণ ও কিবোর্ডে পাঠান", systemImage: "square.and.arrow.up")
                    .font(.headline).frame(maxWidth: .infinity).padding()
                    .background(Color.green).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12))
            }.disabled(voice.transcript.isEmpty)
        }
    }

    private func fixWithAI() {
        guard !voice.transcript.isEmpty else { return }
        isFixingWithAI = true
        aiService.rewrite(text: voice.transcript) { result in
            DispatchQueue.main.async {
                isFixingWithAI = false
                switch result {
                case .success(let output): fixedText = output
                case .failure(let error): voice.errorMessage = "AI: \(error.localizedDescription)"
                }
            }
        }
    }
}
