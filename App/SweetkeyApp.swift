import SwiftUI

@main
struct SweetkeyApp: App {
    @StateObject private var appState = AppState()
    @State private var showVoiceInput = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .sheet(isPresented: $showVoiceInput) {
                    VoiceInputView()
                }
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "sweetkey", url.host == "voice" else { return }
        showVoiceInput = true
    }
}

final class AppState: ObservableObject {
    @Published var fullAccessGranted: Bool = false

    init() {
        checkFullAccess()
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkFullAccess()
        }
    }

    private func checkFullAccess() {
        let defaults = UserDefaults(suiteName: "group.com.sweet.customkeyboard")
        defaults?.set(Date().timeIntervalSince1970, forKey: "last_full_access_check")
        let written = defaults?.synchronize() ?? false
        fullAccessGranted = written
    }
}
