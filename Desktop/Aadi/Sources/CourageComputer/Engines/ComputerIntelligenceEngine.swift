import Foundation
import Combine

public struct ComputerResponse: Sendable {
    public let text: String
    public let intent: UserIntent
    public let threatLevel: ThreatLevel
    public let visualResult: VisionDetectionResult?
    public let investigationReport: InvestigationReport?
    public let shouldSpeak: Bool

    public init(
        text: String,
        intent: UserIntent,
        threatLevel: ThreatLevel = .nominal,
        visualResult: VisionDetectionResult? = nil,
        investigationReport: InvestigationReport? = nil,
        shouldSpeak: Bool = true
    ) {
        self.text = text
        self.intent = intent
        self.threatLevel = threatLevel
        self.visualResult = visualResult
        self.investigationReport = investigationReport
        self.shouldSpeak = shouldSpeak
    }
}

@MainActor
public final class ComputerIntelligenceEngine: ObservableObject {
    public static let shared = ComputerIntelligenceEngine()

    @Published public var currentSystemState: SystemState = .online
    @Published public var isProcessing: Bool = false

    private let personalityEngine = ComputerPersonalityEngine.shared
    private let reasoningEngine = ReasoningEngine.shared
    private let memoryManager = MemoryManager.shared
    private let visionManager = VisionManager.shared
    private let speechManager = SpeechManager.shared
    private let soundSynthesizer = SoundSynthesizer.shared

    public init() {}

    // MARK: - Intent Classification

    public func classifyIntent(for input: String) -> (intent: UserIntent, extractedSlot: String?) {
        let clean = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if clean.contains("what is that") || clean.contains("what do you see") ||
           clean.contains("look at this") || clean.contains("analyze this") ||
           clean.contains("scan this") || clean.contains("identify") || clean.contains("what is this") {
            return (.visionQuery, nil)
        }

        if clean.contains("remember") || clean.contains("have you seen") ||
           clean.contains("did i show") || clean.contains("seen this before") ||
           clean.contains("earlier") || clean.contains("past") {
            var slot: String? = nil
            let words = clean.components(separatedBy: " ")
            if let idx = words.firstIndex(of: "the"), idx + 1 < words.count {
                slot = words[idx + 1]
            } else if let idx = words.firstIndex(of: "about"), idx + 1 < words.count {
                slot = words[idx + 1]
            }
            return (.memoryQuery, slot)
        }

        if clean.contains("investigate") || clean.contains("something is wrong") ||
           clean.contains("did you hear that") || clean.contains("check the room") ||
           clean.contains("anomaly") || clean.contains("examine") || clean.contains("creaking") {
            return (.investigation, nil)
        }

        if clean.contains("danger") || clean.contains("safe") ||
           clean.contains("threat") || clean.contains("harm") ||
           clean.contains("scared") || clean.contains("kill") {
            return (.threatCheck, nil)
        }

        if clean.contains("status") || clean.contains("diagnostic") ||
           clean.contains("who are you") || clean.contains("system") ||
           clean.contains("specs") || clean.contains("uptime") {
            return (.systemStatus, nil)
        }

        if clean == "hello" || clean == "hi" || clean == "computer" ||
           clean.starts(with: "hello ") || clean.starts(with: "hey") || clean.starts(with: "greetings") {
            return (.greeting, nil)
        }

        if clean == "help" || clean == "manual" || clean == "commands" || clean.contains("what can you do") {
            return (.help, nil)
        }

        if clean.contains("feeling") || clean.contains("feel") ||
           clean.contains("afraid") || clean.contains("smart") ||
           clean.contains("love") || clean.contains("friend") || clean.contains("alive") {
            return (.philosophical, nil)
        }

        if clean.hasSuffix("?") || clean.starts(with: "why") || clean.starts(with: "how") || clean.starts(with: "what") {
            return (.question, nil)
        }

        return (.unknown, nil)
    }

    // MARK: - Process Pipeline (Async / Await)

    public func process(userInput: String) async -> ComputerResponse {
        soundSynthesizer.playKeyClick()
        isProcessing = true
        currentSystemState = .analyzing

        let (intent, slot) = classifyIntent(for: userInput)

        _ = memoryManager.record(
            category: .conversation,
            title: "USER PROMPT",
            content: userInput,
            importance: 0.4,
            threatLevel: .nominal,
            tags: [intent.rawValue]
        )

        // Simulate fast terminal processing delay
        try? await Task.sleep(nanoseconds: 350_000_000)

        let response: ComputerResponse
        switch intent {
        case .visionQuery:
            response = await handleVisionQuery()

        case .memoryQuery:
            response = handleMemoryQuery(slot: slot)

        case .investigation:
            response = await handleInvestigation()

        case .threatCheck:
            let text = personalityEngine.formulateDirectAnswer(intent: .threatCheck, rawInput: userInput)
            response = ComputerResponse(text: text, intent: .threatCheck, threatLevel: .elevated)

        case .systemStatus:
            let text = personalityEngine.formulateDirectAnswer(intent: .systemStatus, rawInput: userInput)
            response = ComputerResponse(text: text, intent: .systemStatus, threatLevel: .nominal)

        case .greeting, .philosophical, .help, .question, .unknown, .objectQuery:
            let text = personalityEngine.formulateDirectAnswer(intent: intent, rawInput: userInput)
            response = ComputerResponse(text: text, intent: intent, threatLevel: .nominal)
        }

        isProcessing = false
        currentSystemState = (response.threatLevel == .high || response.threatLevel == .severe) ? .warning : .online

        if response.threatLevel == .high || response.threatLevel == .severe {
            soundSynthesizer.playAlert()
        } else {
            soundSynthesizer.playConfirm()
        }

        _ = memoryManager.record(
            category: intent == .investigation ? .anomaly : .observation,
            title: "COMPUTER RESPONSE [\(intent.rawValue.uppercased())]",
            content: response.text,
            importance: 0.6,
            threatLevel: response.threatLevel,
            tags: ["response", intent.rawValue]
        )

        if response.shouldSpeak {
            speechManager.speak(response.text)
        }

        return response
    }

    public func process(userInput: String, completion: @escaping @MainActor (ComputerResponse) -> Void) {
        Task { @MainActor in
            let res = await self.process(userInput: userInput)
            completion(res)
        }
    }

    // MARK: - Specialized Handlers

    private func handleVisionQuery() async -> ComputerResponse {
        let result = await visionManager.analyzeCurrentViewAsync()

        let prior = memoryManager.findRecentObject(query: result.primaryObject)
        let isRecurrent = prior != nil

        let reasoningInput = ReasoningInput(
            objectName: result.primaryObject,
            confidence: result.confidence,
            audioDecibels: speechManager.audioLevel,
            ambientLux: visionManager.ambientLux,
            motionVariance: visionManager.frameMotionVariance,
            previousEncounterCount: isRecurrent ? 1 : 0
        )
        let deduction = reasoningEngine.deduce(input: reasoningInput)

        let text = personalityEngine.formulateVisionResponse(
            object: result.primaryObject,
            confidence: result.confidence,
            threat: deduction.threatLevel,
            isRecurrent: isRecurrent
        )

        _ = memoryManager.record(
            category: .object,
            title: "OBJECT: \(result.primaryObject.uppercased())",
            content: "Confidence: \(result.confidencePercentage)%. Threat: \(deduction.threatLevel.rawValue).",
            importance: deduction.threatScore,
            threatLevel: deduction.threatLevel,
            tags: ["vision", result.primaryObject.lowercased()]
        )

        return ComputerResponse(
            text: text,
            intent: .visionQuery,
            threatLevel: deduction.threatLevel,
            visualResult: result
        )
    }

    private func handleMemoryQuery(slot: String?) -> ComputerResponse {
        let match = memoryManager.findRecentObject(query: slot)
        let text = personalityEngine.formulateMemoryRecall(
            foundObject: match?.title,
            timestamp: match?.timestamp,
            totalCount: memoryManager.entries.count
        )
        return ComputerResponse(text: text, intent: .memoryQuery, threatLevel: match?.threatLevel ?? .nominal)
    }

    public func handleInvestigation() async -> ComputerResponse {
        let result = await visionManager.analyzeCurrentViewAsync()
        let obj = result.primaryObject
        let conf = result.confidence
        let audioDb = speechManager.audioLevel
        let lux = visionManager.ambientLux
        let motion = visionManager.frameMotionVariance

        let reasoningInput = ReasoningInput(
            objectName: obj,
            confidence: conf,
            audioDecibels: audioDb,
            ambientLux: lux,
            motionVariance: motion,
            previousEncounterCount: memoryManager.totalAnomaliesCount
        )

        let deduction = reasoningEngine.deduce(input: reasoningInput)

        let report = InvestigationReport(
            targetDescription: obj,
            opticalFinding: "\(obj) (\(Int(conf * 100))% match)",
            audioDecibels: audioDb,
            lightLevelLux: lux,
            motionVariance: motion,
            anomalyIndex: deduction.threatScore,
            correlationSteps: deduction.correlationFactors,
            threatLevel: deduction.threatLevel,
            deduction: deduction.primaryDeduction,
            advisory: deduction.tacticalRecommendation
        )

        let text = personalityEngine.formulateInvestigationVerdict(
            target: obj,
            opticalFinding: report.opticalFinding,
            audioDb: audioDb,
            lux: lux,
            threat: deduction.threatLevel,
            deduction: deduction.primaryDeduction,
            advisory: deduction.tacticalRecommendation
        )

        _ = memoryManager.record(
            category: .anomaly,
            title: "INVESTIGATION: \(obj.uppercased())",
            content: "Threat: \(deduction.threatLevel.rawValue). Anomaly Index: \(String(format: "%.2f", deduction.threatScore)).",
            importance: 0.9,
            threatLevel: deduction.threatLevel,
            tags: ["investigate", "report", obj.lowercased()]
        )

        return ComputerResponse(
            text: text,
            intent: .investigation,
            threatLevel: deduction.threatLevel,
            investigationReport: report
        )
    }
}
