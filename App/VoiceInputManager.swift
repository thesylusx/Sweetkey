import Foundation
import AVFoundation
import Speech

@MainActor
final class VoiceInputManager: ObservableObject {
    enum AuthStatus { case unknown, denied, authorized }

    @Published var isRecording = false
    @Published var transcript = ""
    @Published var errorMessage: String?
    @Published var authStatus: AuthStatus = .unknown

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer: SFSpeechRecognizer?

    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "bn-BD"))
            ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    func requestPermissions() async {
        let speechStatus: SFSpeechRecognizerAuthorizationStatus = await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { cont.resume(returning: $0) }
        }
        let micGranted: Bool = await withCheckedContinuation { cont in
            AVAudioSession.sharedInstance().requestRecordPermission { cont.resume(returning: $0) }
        }
        if speechStatus == .authorized && micGranted {
            authStatus = .authorized
        } else {
            authStatus = .denied
            errorMessage = "Microphone ও Speech Recognition অনুমতি প্রয়োজন। Settings → Sweetkey-এ গিয়ে চালু করুন।"
        }
    }

    func startRecording() {
        guard authStatus == .authorized else { errorMessage = "প্রথমে অনুমতি দিন।"; return }
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer এখন উপলব্ধ নয়।"; return
        }
        transcript = ""; errorMessage = ""
        recognitionTask?.cancel(); recognitionTask = nil
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let request = recognitionRequest else { return }
            request.shouldReportPartialResults = true
            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }
                Task { @MainActor in
                    if let result {
                        self.transcript = result.bestTranscription.formattedString
                        if result.isFinal { self.stopRecording() }
                    }
                    if error != nil { self.stopRecording() }
                }
            }
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "রেকর্ডিং শুরু করা যায়নি: \(error.localizedDescription)"
            stopRecording()
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio(); recognitionRequest = nil
        recognitionTask?.cancel(); recognitionTask = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
