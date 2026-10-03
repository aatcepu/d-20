import Foundation

public struct ReasoningInput {
    public let objectName: String
    public let confidence: Double
    public let audioDecibels: Float
    public let ambientLux: Double
    public let motionVariance: Double
    public let hourOfDay: Int
    public let previousEncounterCount: Int

    public init(
        objectName: String = "Unknown",
        confidence: Double = 0.8,
        audioDecibels: Float = -40.0,
        ambientLux: Double = 50.0,
        motionVariance: Double = 0.05,
        hourOfDay: Int = Calendar.current.component(.hour, from: Date()),
        previousEncounterCount: Int = 0
    ) {
        self.objectName = objectName
        self.confidence = confidence
        self.audioDecibels = audioDecibels
        self.ambientLux = ambientLux
        self.motionVariance = motionVariance
        self.hourOfDay = hourOfDay
        self.previousEncounterCount = previousEncounterCount
    }
}

public struct ReasoningOutput {
    public let threatLevel: ThreatLevel
    public let threatScore: Double
    public let anomalyProbability: Double
    public let primaryDeduction: String
    public let secondaryObservation: String
    public let tacticalRecommendation: String
    public let correlationFactors: [String]
}

public final class ReasoningEngine: Sendable {
    public static let shared = ReasoningEngine()

    public init() {}

    public func deduce(input: ReasoningInput) -> ReasoningOutput {
        var baseThreatScore: Double = 0.1
        var factors: [String] = []

        let obj = input.objectName.lowercased()

        // 1. Object specific threat heuristics
        if obj.contains("cat") || obj.contains("feline") {
            baseThreatScore = 0.22
            factors.append("Domestic quadruped. High probability of willful disregard for human authority.")
        } else if obj.contains("urn") || obj.contains("curse") || obj.contains("relic") || obj.contains("artifact") {
            baseThreatScore = 0.88
            factors.append("Ancient antiquities carry 94.2% historical correlation with localized spectral unrest.")
        } else if obj.contains("parcel") || obj.contains("box") || obj.contains("package") {
            baseThreatScore = 0.65
            factors.append("Unprompted delivery to an isolated farmhouse violates standard postal probability.")
        } else if obj.contains("shadow") || obj.contains("figure") || obj.contains("entity") {
            baseThreatScore = 0.94
            factors.append("Photometric void confirmed. Entity does not conform to biological optics.")
        } else if obj.contains("mask") {
            baseThreatScore = 0.89
            factors.append("Ceremonial facial prosthesis. Known catalyst for involuntary possession.")
        } else if obj.contains("tea") || obj.contains("cup") || obj.contains("mug") {
            baseThreatScore = 0.08
            factors.append("Standard ceramic containment vessel for heated domestic liquids.")
        } else {
            baseThreatScore = 0.35
            factors.append("Object matches generic terrestrial taxonomy.")
        }

        // 2. Audio anomaly factor
        if input.audioDecibels > -18.0 {
            baseThreatScore += 0.20
            factors.append("Acoustic amplitude exceeds peaceful nocturnal baseline (-18.0 dB).")
        } else if input.audioDecibels < -55.0 {
            baseThreatScore += 0.10
            factors.append("Unnatural silence observed. Lack of insectoid or wind frequency resonance.")
        }

        // 3. Ambient Lux (Darkness vs harsh glare)
        if input.ambientLux < 15.0 {
            baseThreatScore += 0.15
            factors.append("Sub-critical illumination level (< 15 Lux). Human visual acuity degraded.")
        }

        // 4. Motion factor
        if input.motionVariance > 0.25 {
            baseThreatScore += 0.18
            factors.append("Rapid or erratic kinetic oscillation detected.")
        }

        // 5. Temporal factor (Late night / Early morning)
        if input.hourOfDay >= 0 && input.hourOfDay <= 4 {
            baseThreatScore += 0.15
            factors.append("Temporal index (00:00 - 04:00) represents statistical peak for inexplicable events.")
        }

        // 6. Recurrence factor
        if input.previousEncounterCount > 0 {
            factors.append("Recurrent encounter: Target was logged \(input.previousEncounterCount) time(s) previously.")
        }

        let clampedScore = max(0.02, min(0.99, baseThreatScore))

        let threatLevel: ThreatLevel
        switch clampedScore {
        case 0.0..<0.20: threatLevel = .nominal
        case 0.20..<0.45: threatLevel = .low
        case 0.45..<0.75: threatLevel = .elevated
        case 0.75..<0.90: threatLevel = .high
        default: threatLevel = .severe
        }

        // Deductions & recommendations
        let (deduction, secondary, advisory) = generateNarrative(
            object: input.objectName,
            threat: threatLevel,
            recurrence: input.previousEncounterCount,
            lux: input.ambientLux
        )

        return ReasoningOutput(
            threatLevel: threatLevel,
            threatScore: clampedScore,
            anomalyProbability: clampedScore * 0.92,
            primaryDeduction: deduction,
            secondaryObservation: secondary,
            tacticalRecommendation: advisory,
            correlationFactors: factors
        )
    }

    private func generateNarrative(
        object: String,
        threat: ThreatLevel,
        recurrence: Int,
        lux: Double
    ) -> (String, String, String) {
        let objLower = object.lowercased()

        if objLower.contains("cat") {
            let primary = "Feline biological unit. Internal purr mechanism operational."
            let secondary = recurrence > 0 ? "It has returned. It remembered you have thumbs." : "It is examining you as though you were an incompetent subordinate."
            let advisory = "Do not attempt to negotiate. Provide poultry or maintain respectful distance."
            return (primary, secondary, advisory)
        }

        if objLower.contains("urn") || objLower.contains("curse") {
            let primary = "Centuries-old funerary relic with an active ethereal grievance."
            let secondary = "The carvings clearly warn of a plague of locusts or eternal dry rot."
            let advisory = "Put it back where you found it immediately. Do not touch the lid."
            return (primary, secondary, advisory)
        }

        if objLower.contains("parcel") {
            let primary = "Enclosed cardboard parcel vibrating in three distinct tempos."
            let secondary = "Postal regulations do not permit packages that hiss."
            let advisory = "Do not open it with kitchen scissors. Relocate outside the cellar."
            return (primary, secondary, advisory)
        }

        if objLower.contains("shadow") {
            let primary = "Optical silhouette with neither light source nor biological occupant."
            let secondary = "It moved toward the screen the moment you looked away."
            let advisory = "Close the shutters. Barricade the attic hatch. Prepare to shriek."
            return (primary, secondary, advisory)
        }

        if objLower.contains("mask") {
            let primary = "Hand-carved facial facade vibrating at 432 Hertz."
            let secondary = "Historical archives indicate whoever wears it will acquire malicious confidence."
            let advisory = "Keep it away from the elderly farmer. He lacks the fortitude to resist."
            return (primary, secondary, advisory)
        }

        // Generic fallback based on threat
        switch threat {
        case .nominal:
            return (
                "Object is mundane and physically compliant with known physics.",
                "Zero supernatural resonance detected.",
                "You may proceed without panic, though knowing you, you will panic anyway."
            )
        case .low:
            return (
                "Object exhibits minor behavioral idiosyncrasies.",
                "Unlikely to destroy the farmhouse before sunrise.",
                "Monitor its coordinates. Do not feed it after twilight."
            )
        case .elevated:
            return (
                "Thermal and optical readings demonstrate a non-standard entropy gradient.",
                "Past incidents in this county suggest trouble is imminent.",
                "Keep a wooden mallet or sturdy flashlight within arm's reach."
            )
        case .high:
            return (
                "High-potency paranormal anomaly confirmed.",
                "Standard physics have politely vacated the premises.",
                "Run in circular trajectories while vocalizing high-pitched distress."
            )
        case .severe:
            return (
                "Catastrophic anomaly detected. Immediate reality distortion imminent.",
                "The odds of standard household insurance covering this are zero.",
                "Save yourself. Leave the dog. Actually, the dog usually solves this."
            )
        }
    }
}
