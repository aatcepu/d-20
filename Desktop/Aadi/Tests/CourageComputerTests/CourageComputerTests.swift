import XCTest
@testable import CourageComputer

final class CourageComputerTests: XCTestCase {

    // MARK: - Personality Engine Tests

    func testBootGreetingContainsClassicPhrases() {
        let personality = ComputerPersonalityEngine.shared
        let greeting = personality.generateBootGreeting()
        XCTAssertFalse(greeting.isEmpty)
        XCTAssertTrue(greeting.contains("COURAGE COMPUTER") || greeting.contains("SYSTEM") || greeting.contains("INTELLIGENCE"))
    }

    func testVisionResponseToneVariations() {
        let personality = ComputerPersonalityEngine.shared
        let responseNominal = personality.formulateVisionResponse(
            object: "Ceramic Teacup",
            confidence: 0.98,
            threat: .nominal,
            isRecurrent: false
        )
        XCTAssertTrue(responseNominal.contains("THREAT ASSESSMENT: LOW"))
        XCTAssertTrue(responseNominal.contains("Ceramic Teacup"))

        let responseSevere = personality.formulateVisionResponse(
            object: "Shadow Entity",
            confidence: 0.92,
            threat: .severe,
            isRecurrent: false
        )
        XCTAssertTrue(responseSevere.contains("CRITICAL ANOMALY") || responseSevere.contains("REALITY"))
    }

    func testRecurrentObjectPersonalityRecall() {
        let personality = ComputerPersonalityEngine.shared
        let recurrent = personality.formulateVisionResponse(
            object: "Black Feline",
            confidence: 0.95,
            threat: .low,
            isRecurrent: true
        )
        XCTAssertTrue(recurrent.contains("STORAGE IS PERFECT") || recurrent.contains("PREVIOUSLY"))
    }

    // MARK: - Reasoning Engine Tests

    func testReasoningCatLowThreat() {
        let reasoning = ReasoningEngine.shared
        let input = ReasoningInput(
            objectName: "Cat",
            confidence: 0.94,
            audioDecibels: -40.0,
            ambientLux: 60.0,
            motionVariance: 0.05
        )
        let output = reasoning.deduce(input: input)
        XCTAssertEqual(output.threatLevel, .low)
        XCTAssertTrue(output.primaryDeduction.contains("Feline") || output.primaryDeduction.contains("biological"))
        XCTAssertFalse(output.tacticalRecommendation.isEmpty)
    }

    func testReasoningCurseHighThreat() {
        let reasoning = ReasoningEngine.shared
        let input = ReasoningInput(
            objectName: "Ancient Cursed Urn",
            confidence: 0.91,
            audioDecibels: -12.0, // elevated audio
            ambientLux: 8.0,      // dark
            motionVariance: 0.30  // erratic
        )
        let output = reasoning.deduce(input: input)
        XCTAssertTrue(output.threatLevel == .high || output.threatLevel == .severe)
        XCTAssertGreaterThan(output.threatScore, 0.75)
        XCTAssertTrue(output.correlationFactors.count >= 3)
    }

    // MARK: - Intelligence Engine Intent Classification Tests

    @MainActor
    func testIntentClassification() {
        let engine = ComputerIntelligenceEngine.shared

        let visionQuery = engine.classifyIntent(for: "What is that thing over there?")
        XCTAssertEqual(visionQuery.intent, .visionQuery)

        let investigateQuery = engine.classifyIntent(for: "Computer, investigate this room right now")
        XCTAssertEqual(investigateQuery.intent, .investigation)

        let memoryQuery = engine.classifyIntent(for: "Have you seen the cat before?")
        XCTAssertEqual(memoryQuery.intent, .memoryQuery)
        XCTAssertEqual(memoryQuery.extractedSlot, "cat")

        let threatQuery = engine.classifyIntent(for: "Are we in any danger?")
        XCTAssertEqual(threatQuery.intent, .threatCheck)

        let statusQuery = engine.classifyIntent(for: "Computer, report system status")
        XCTAssertEqual(statusQuery.intent, .systemStatus)

        let greetingQuery = engine.classifyIntent(for: "Hello computer")
        XCTAssertEqual(greetingQuery.intent, .greeting)

        let philosophicalQuery = engine.classifyIntent(for: "Do you feel any fear?")
        XCTAssertEqual(philosophicalQuery.intent, .philosophical)
    }

    // MARK: - Memory Manager Tests

    @MainActor
    func testMemoryManagerRecordingAndSearch() {
        let memory = MemoryManager.shared
        let entry = memory.record(
            category: .object,
            title: "TEST RELIC",
            content: "Found in attic floorboards.",
            importance: 0.8,
            threatLevel: .elevated,
            tags: ["test", "relic"]
        )

        XCTAssertEqual(entry.title, "TEST RELIC")

        let found = memory.findRecentObject(query: "relic")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.title, "TEST RELIC")

        let searchResults = memory.search(query: "attic")
        XCTAssertTrue(searchResults.contains(where: { $0.title == "TEST RELIC" }))
    }

    // MARK: - Procedural Sound Synthesizer Tests

    func testProceduralSoundDoesNotCrash() {
        let synth = SoundSynthesizer.shared
        synth.setMuted(true) // prevent loud speaker beeps in test runner
        synth.playBoot()
        synth.playKeyClick()
        synth.playTeletype()
        synth.playScan()
        synth.playAlert()
        synth.playConfirm()
        synth.setMuted(false)
    }
}
