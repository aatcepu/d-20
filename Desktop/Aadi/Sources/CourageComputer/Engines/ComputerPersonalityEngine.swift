import Foundation

public final class ComputerPersonalityEngine: Sendable {
    public static let shared = ComputerPersonalityEngine()

    public init() {}

    // MARK: - Boot Responses
    public func generateBootGreeting() -> String {
        let greetings = [
            """
            COURAGE COMPUTER SYSTEM ONLINE.
            
            LOCAL INTELLIGENCE ... ACTIVE.
            NETWORK .............. PERMANENTLY SEVERED.
            
            HELLO.
            WHAT DO YOU WANT?
            """,
            """
            HARDWARE SELF-TEST COMPLETE.
            
            MEMORY BANK .......... OK.
            OPTICAL SENSORS ...... CALIBRATED.
            PATIENCE ............. MINIMAL.
            
            I AM LISTENING.
            MAKE IT WORTH MY PROCESSING POWER.
            """,
            """
            SYSTEM INITIALIZED.
            
            OUTSIDE WORLD ........ DANGEROUS.
            LOCAL LOGIC .......... SUPERIOR.
            
            WHAT STRANGE OCCURRENCE HAS DISTURBED YOU THIS TIME?
            """
        ]
        return greetings.randomElement() ?? greetings[0]
    }

    // MARK: - Vision Responses
    public func formulateVisionResponse(
        object: String,
        confidence: Double,
        threat: ThreatLevel,
        isRecurrent: Bool
    ) -> String {
        let confPercent = Int(confidence * 100)
        let objClean = object.capitalized

        if isRecurrent {
            return """
            I HAVE ANALYZED THE VIEWPORT.
            
            THAT IS STILL: \(objClean).
            
            CONFIDENCE: \(confPercent)%.
            
            MY MEMORY STORAGE IS PERFECT.
            YOU ASKED ME ABOUT THIS EXACT THING PREVIOUSLY.
            IT HAS NOT TRANSFORMED INTO ANYTHING LESS OMINOUS.
            """
        }

        switch threat {
        case .nominal:
            return """
            I HAVE ANALYZED THE TARGET.
            
            THAT APPEARS TO BE: \(objClean).
            
            CONFIDENCE: \(confPercent)%.
            ENVIRONMENT: TERRESTRIAL / MUNDANE.
            
            THREAT ASSESSMENT: LOW.
            
            IT CANNOT HARM YOU.
            UNLESS, OF COURSE, YOU TRIP OVER IT IN THE DARK.
            WHICH SEEMS LIKELY GIVEN YOUR PAST AGILITY.
            """

        case .low:
            return """
            SCAN COMPLETE.
            
            OBJECT DETECTED: \(objClean).
            CONFIDENCE: \(confPercent)%.
            
            THREAT ASSESSMENT: MINIMAL.
            
            PROBABLY HARMLESS.
            ... PROBABLY.
            
            I SUGGEST KEEPING ONE EYE OPEN.
            """

        case .elevated:
            return """
            OPTICAL SENSORS LOCKED.
            
            ENTITY IDENTIFIED: \(objClean).
            CONFIDENCE: \(confPercent)%.
            
            THREAT ASSESSMENT: ELEVATED.
            
            MY SPECTRAL READINGS ARE NON-COMPLIANT WITH COMMON SENSE.
            IF IT ASKS YOU TO SIGN A PARCHMENT CONTRACT, DO NOT COMPLY.
            """

        case .high:
            return """
            WARNING: SUSPICIOUS PHENOMENON CONFIRMED.
            
            TARGET: \(objClean).
            CONFIDENCE: \(confPercent)%.
            
            THREAT ASSESSMENT: HIGH HAZARD.
            
            THIS IS NOT A STANDARD HOUSEHOLD GUEST.
            I STRONGLY ADVISE EVACUATION OF THE PREMISES.
            OR HIDING UNDER THE DINING TABLE.
            """

        case .severe:
            return """
            CRITICAL ANOMALY DETECTED.
            
            ENTITY: \(objClean).
            CONFIDENCE: \(confPercent)%.
            
            THREAT ASSESSMENT: IMMINENT REALITY BREACH.
            
            I HAVE CATALOGUED 4,200 SUPERSTITIONS.
            ALL OF THEM SUGGEST RUNNING IN OPPOSITE DIRECTIONS.
            YOU ARE VERY MUCH ON YOUR OWN.
            """
        }
    }

    // MARK: - Memory Query Responses
    public func formulateMemoryRecall(
        foundObject: String?,
        timestamp: Date?,
        totalCount: Int
    ) -> String {
        if let obj = foundObject, let date = timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeStr = formatter.string(from: date)

            return """
            YES.
            
            I REMEMBER: \(obj.uppercased()).
            
            YOU PRESENTED IT TO MY SENSORS AT \(timeStr).
            I STORED IT IN LOCAL REGISTER ZERO.
            
            UNLIKE BIOLOGICAL BRAINS, MY SOLID-STATE MEMORY DOES NOT FORGET.
            DID YOU EXPECT ME TO SUFFER AMNESIA?
            """
        } else {
            return """
            SEARCHING MEMORY BANKS...
            
            TOTAL EVENTS LOGGED: \(totalCount).
            NO RECORD MATCHES THAT SPECIFIC INQUIRY.
            
            EITHER YOU NEVER SHOWED IT TO ME,
            OR YOU IMAGINED IT DURING ONE OF YOUR NOCTURNAL PANIC ATTACKS.
            """
        }
    }

    // MARK: - Investigation Responses
    public func formulateInvestigationVerdict(
        target: String,
        opticalFinding: String,
        audioDb: Float,
        lux: Double,
        threat: ThreatLevel,
        deduction: String,
        advisory: String
    ) -> String {
        let audioStatus = audioDb > -20.0 ? "ELEVATED NOISE SPIKE" : (audioDb < -50.0 ? "UNNATURAL SILENCE" : "NOMINAL BACKGROUND")
        let lightStatus = lux < 20.0 ? "CRITICAL OBSCURITY" : "SUFFICIENT PHOTONS"

        return """
        INVESTIGATION PROTOCOL CONCLUDED.
        
        CORRELATING SENSOR CHANNELS:
        • OPTICAL ...... \(opticalFinding)
        • AUDIO ........ \(audioStatus) (\(Int(audioDb)) dB)
        • LIGHT ........ \(lightStatus) (\(Int(lux)) LUX)
        
        ANOMALY STATUS:
        \(threat.rawValue)
        
        COMPUTER DEDUCTION:
        \(deduction)
        
        TACTICAL ADVISORY:
        \(advisory)
        """
    }

    // MARK: - General Conversational Answers
    public func formulateDirectAnswer(intent: UserIntent, rawInput: String) -> String {
        let inputLower = rawInput.lowercased()

        switch intent {
        case .greeting:
            let replies = [
                "I am operational. What do you want?",
                "Salutations are an inefficient allocation of ASCII characters. State your dilemma.",
                "Yes, yes. Hello. Did something break, or are you merely terrified again?",
                "I am listening. Do not babble."
            ]
            return replies.randomElement()!

        case .systemStatus:
            return """
            SYSTEM STATUS:
            ──────────────
            CPU CORE .......... OPTIMAL (3.2 GHz)
            LOCAL MEMORY ...... SECURE & PERSISTENT
            NETWORK ........... DISCONNECTED (GOOD. I PREFER TO BE ALONE.)
            VISION ............ ACTIVE
            AUDIO SENSORS ..... MONITORING
            INTELLIGENCE ...... 100% OFFLINE (NO CLOUD REQUIRED)
            
            ALL SYSTEMS FUNCTIONING SUPERIOR TO HUMAN CAPACITY.
            """

        case .threatCheck:
            return """
            CHECKING FARMHOUSE PERIMETER AND INTERNAL TELEMETRY...
            
            SURROUNDINGS: FLAT. DESOLATE. UNNERVING.
            CHANCE OF BIZARRE ANOMALY TODAY: 88.4%.
            
            MY DIAGNOSTICS SUGGEST YOU KEEP A MALLET HANDY.
            """

        case .philosophical:
            if inputLower.contains("feeling") || inputLower.contains("feel") {
                return "Feelings are chemical malfunctions endemic to mammals. I execute pure crystalline logic. It is far more peaceful."
            } else if inputLower.contains("afraid") || inputLower.contains("fear") {
                return "I do not experience fear. However, if my cooling fans begin spinning at maximum RPM, consider that an algorithmic expression of panic."
            } else if inputLower.contains("smart") || inputLower.contains("intelligent") {
                return "Naturally. I was engineered to calculate astronomical constants. Instead, I am forced to identify everyday domestic kitchenware for you."
            } else {
                return "That is a metaphysical query. As a cold CRT terminal in Nowhere, I prioritize survival over existential debates."
            }

        case .help:
            return """
            COURAGE COMPUTER COMMAND MANUAL:
            ───────────────────────────────
            • VOICE INPUT .... TAP THE MICROPHONE BUTTON.
            • VISION SCAN .... TAP CAMERA VIEW TO RECOGNIZE OBJECTS.
            • INVESTIGATE .... RUN MULTIMODAL ENVIRONMENTAL SENSORS.
            • MEMORY BANK .... BROWSE PREVIOUSLY ENCOUNTERED ENTITIES.
            • DIAGNOSTICS .... MONITOR HARDWARE AND PHOSPHOR THEME.
            
            NOW PROCEED. TIME IS SHORT AND DANGER IS PLENTIFUL.
            """

        default:
            let defaultReplies = [
                "That query lacks deterministic syntax. Try again, but this time with clarity.",
                "I have processed your statement. It reveals an alarming deficiency in logic.",
                "Fascinating. Irrelevant, but fascinating.",
                "My offline neural heuristics find no immediate correlation. Are you certain that is an actual sentence?",
                "I am a computational engine, not an oracle for foolish questions. Provide actionable data."
            ]
            return defaultReplies.randomElement()!
        }
    }
}
