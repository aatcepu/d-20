import Foundation
import AVFoundation
import Speech
import Combine

@MainActor
public final class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = SpeechManager()

    @Published public var isSpeaking: Bool = false
    @Published public var isListening: Bool = false
    @Published public var audioLevel: Float = -45.0 // dB
    @Published public var transcribedText: String = ""
    @Published public var speechRecognitionAvailable: Bool = false

    private let synthesizer = AVSpeechSynthesizer()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    public var pitchMultiplier: Float = 0.85
    public var speechRate: Float = 0.46
    public var isVoiceOutputEnabled: Bool = true

    private var levelTimer: Timer?

    public override init() {
        super.init()
        synthesizer.delegate = self
        setupSpeechRecognizer()
    }

    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        if let recognizer = speechRecognizer {
            speechRecognitionAvailable = recognizer.isAvailable
        }
    }

    // MARK: - Speech Output (TTS)

    public func speak(_ text: String, completion: (() -> Void)? = nil) {
        guard isVoiceOutputEnabled else {
            completion?()
            return
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let cleaned = sanitizeForSpeech(text)
        guard !cleaned.isEmpty else {
            completion?()
            return
        }

        let utterance = AVSpeechUtterance(string: cleaned)
        utterance.rate = speechRate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1

        // Prefer English voice with dry / retro characteristics
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.Fred") ??
                      AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-US.Samantha") ??
                      AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }

        DispatchQueue.main.async {
            self.isSpeaking = true
        }

        synthesizer.speak(utterance)
    }

    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }

    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }

    nonisolated public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }

    // MARK: - Speech Input (STT)

    public func startListening(onTranscription: @escaping @Sendable @MainActor (String) -> Void) {
        #if os(iOS) || os(macOS)
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch authStatus {
                case .authorized:
                    self.performLiveListening(onTranscription: onTranscription)
                default:
                    self.simulateVoiceInput(onTranscription: onTranscription)
                }
            }
        }
        #else
        simulateVoiceInput(onTranscription: onTranscription)
        #endif
    }

    private func performLiveListening(onTranscription: @escaping @Sendable @MainActor (String) -> Void) {
        stopListening()

        do {
            #if os(iOS)
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            #endif

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)

            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
                self?.recognitionRequest?.append(buffer)
                self?.updateAudioLevel(from: buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            isListening = true

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    DispatchQueue.main.async {
                        self.transcribedText = text
                        onTranscription(text)
                    }
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stopListening()
                }
            }
        } catch {
            simulateVoiceInput(onTranscription: onTranscription)
        }
    }

    public func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        levelTimer?.invalidate()
        levelTimer = nil

        DispatchQueue.main.async {
            self.isListening = false
        }
    }

    // Fallback simulation when microphone is not permitted or unavailable
    public func simulateVoiceInput(onTranscription: @escaping @Sendable @MainActor (String) -> Void) {
        isListening = true
        let phrases = [
            "Computer, what is that object?",
            "Computer, investigate this anomaly.",
            "Computer, do you remember what I showed you?",
            "Computer, are we in any danger?",
            "Computer, run system diagnostics."
        ]
        let selected = phrases.randomElement() ?? "Computer, what do you see?"

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            for _ in 0..<12 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                guard self.isListening else { return }
                self.audioLevel = Float.random(in: -30.0 ... -8.0)
            }
            self.isListening = false
            self.audioLevel = -45.0
            self.transcribedText = selected
            onTranscription(selected)
        }
    }

    private func updateAudioLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        var sum: Float = 0.0
        for sample in channelDataArray {
            sum += sample * sample
        }
        let rms = sqrt(sum / Float(buffer.frameLength))
        let db = 20 * log10(max(rms, 0.00001))
        DispatchQueue.main.async {
            self.audioLevel = max(-60.0, min(0.0, db))
        }
    }

    private func sanitizeForSpeech(_ text: String) -> String {
        var clean = text
        // Remove ASCII art and box borders
        clean = clean.replacingOccurrences(of: "═", with: "")
        clean = clean.replacingOccurrences(of: "─", with: "")
        clean = clean.replacingOccurrences(of: "│", with: "")
        clean = clean.replacingOccurrences(of: "┌", with: "")
        clean = clean.replacingOccurrences(of: "┐", with: "")
        clean = clean.replacingOccurrences(of: "└", with: "")
        clean = clean.replacingOccurrences(of: "┘", with: "")
        clean = clean.replacingOccurrences(of: "█", with: "")
        clean = clean.replacingOccurrences(of: "▓", with: "")
        clean = clean.replacingOccurrences(of: "▒", with: "")
        clean = clean.replacingOccurrences(of: "░", with: "")
        return clean.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
