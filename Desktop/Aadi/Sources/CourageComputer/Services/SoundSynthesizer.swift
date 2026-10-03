import Foundation
import AVFoundation

public final class SoundSynthesizer: @unchecked Sendable {
    public static let shared = SoundSynthesizer()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var isMuted: Bool = false
    private let queue = DispatchQueue(label: "com.courage.soundsynthesizer", qos: .userInitiated)

    private init() {
        pregenerateSounds()
    }

    public func setMuted(_ muted: Bool) {
        self.isMuted = muted
    }

    public func playBoot() {
        playSound(named: "boot")
    }

    public func playKeyClick() {
        playSound(named: "keyclick")
    }

    public func playTeletype() {
        playSound(named: "teletype")
    }

    public func playScan() {
        playSound(named: "scan")
    }

    public func playAlert() {
        playSound(named: "alert")
    }

    public func playConfirm() {
        playSound(named: "confirm")
    }

    private func playSound(named name: String) {
        guard !isMuted else { return }
        queue.async { [weak self] in
            guard let self = self, let player = self.audioPlayers[name] else { return }
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
        }
    }

    private func pregenerateSounds() {
        audioPlayers["boot"] = makeAudioPlayer(samples: generateBootSound())
        audioPlayers["keyclick"] = makeAudioPlayer(samples: generateKeyClick())
        audioPlayers["teletype"] = makeAudioPlayer(samples: generateTeletype())
        audioPlayers["scan"] = makeAudioPlayer(samples: generateScanPing())
        audioPlayers["alert"] = makeAudioPlayer(samples: generateAlert())
        audioPlayers["confirm"] = makeAudioPlayer(samples: generateConfirm())
    }

    private func makeAudioPlayer(samples: [Int16], sampleRate: Double = 44100) -> AVAudioPlayer? {
        let wavData = createWavData(samples: samples, sampleRate: Int(sampleRate))
        do {
            let player = try AVAudioPlayer(data: wavData)
            player.prepareToPlay()
            return player
        } catch {
            return nil
        }
    }

    // MARK: - Procedural Waveforms

    private func generateBootSound() -> [Int16] {
        let sampleRate: Double = 44100
        let duration: Double = 1.4
        let totalSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate

            // Degauss thump (decaying low frequency pulse)
            let thumpFreq = 65.0 - (t * 30.0)
            let thump = sin(2.0 * .pi * thumpFreq * t) * exp(-t * 5.0)

            // CRT coil whine (15,734 Hz simulated sub-harmonic at ~7867Hz / 3933Hz)
            let whine = sin(2.0 * .pi * 3933.0 * t) * 0.12 * (1.0 - exp(-t * 8.0))

            // Transformer hum (60Hz + 120Hz harmonics)
            let hum = (sin(2.0 * .pi * 60.0 * t) + 0.4 * sin(2.0 * .pi * 120.0 * t)) * 0.25 * (1.0 - exp(-t * 4.0))

            // Relay click at 0.3s
            var click = 0.0
            if t > 0.3 && t < 0.34 {
                let ct = t - 0.3
                click = sin(2.0 * .pi * 1800.0 * ct) * exp(-ct * 120.0) * 0.7
            }

            let mix = (thump * 0.65 + whine + hum + click) * 0.75
            let clamped = max(-1.0, min(1.0, mix))
            samples[i] = Int16(clamped * 32767.0)
        }
        return samples
    }

    private func generateKeyClick() -> [Int16] {
        let sampleRate: Double = 44100
        let duration: Double = 0.04
        let totalSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let noise = Double.random(in: -1.0...1.0)
            let tone = sin(2.0 * .pi * 2400.0 * t)
            let envelope = exp(-t * 180.0)
            let mix = (noise * 0.4 + tone * 0.6) * envelope * 0.85
            samples[i] = Int16(max(-1.0, min(1.0, mix)) * 32767.0)
        }
        return samples
    }

    private func generateTeletype() -> [Int16] {
        let sampleRate: Double = 44100
        let duration: Double = 0.02
        let totalSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let noise = Double.random(in: -1.0...1.0)
            let tone = sin(2.0 * .pi * 3200.0 * t)
            let envelope = exp(-t * 260.0)
            let mix = (noise * 0.5 + tone * 0.5) * envelope * 0.5
            samples[i] = Int16(max(-1.0, min(1.0, mix)) * 32767.0)
        }
        return samples
    }

    private func generateScanPing() -> [Int16] {
        let sampleRate: Double = 44100
        let duration: Double = 0.35
        let totalSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let freq = 1400.0 - (t * 1200.0)
            let tone = sin(2.0 * .pi * freq * t)
            let envelope = exp(-t * 8.0)
            let mix = tone * envelope * 0.75
            samples[i] = Int16(max(-1.0, min(1.0, mix)) * 32767.0)
        }
        return samples
    }

    private func generateAlert() -> [Int16] {
        let sampleRate: Double = 44100
        let duration: Double = 0.45
        let totalSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let freq: Double = (Int(t * 14.0) % 2 == 0) ? 880.0 : 587.33
            let tone = sin(2.0 * .pi * freq * t)
            let envelope = min(1.0, (duration - t) * 6.0)
            let mix = tone * envelope * 0.8
            samples[i] = Int16(max(-1.0, min(1.0, mix)) * 32767.0)
        }
        return samples
    }

    private func generateConfirm() -> [Int16] {
        let sampleRate: Double = 44100
        let duration: Double = 0.16
        let totalSamples = Int(sampleRate * duration)
        var samples = [Int16](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let freq = t < 0.08 ? 800.0 : 1200.0
            let tone = sin(2.0 * .pi * freq * t)
            let envelope = exp(-(t.truncatingRemainder(dividingBy: 0.08)) * 30.0)
            let mix = tone * envelope * 0.65
            samples[i] = Int16(max(-1.0, min(1.0, mix)) * 32767.0)
        }
        return samples
    }

    // MARK: - WAV Header Builder

    private func createWavData(samples: [Int16], sampleRate: Int) -> Data {
        var data = Data()
        let numChannels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let byteRate = Int32(sampleRate * Int(numChannels) * Int(bitsPerSample / 8))
        let blockAlign = Int16(numChannels * (bitsPerSample / 8))
        let dataSize = Int32(samples.count * 2)
        let chunkSize = 36 + dataSize

        // RIFF chunk
        data.append(contentsOf: "RIFF".utf8)
        data.append(contentsOf: withUnsafeBytes(of: chunkSize.littleEndian) { Array($0) })
        data.append(contentsOf: "WAVE".utf8)

        // fmt subchunk
        data.append(contentsOf: "fmt ".utf8)
        let subchunk1Size: Int32 = 16
        let audioFormat: Int16 = 1 // PCM
        data.append(contentsOf: withUnsafeBytes(of: subchunk1Size.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: audioFormat.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: Int32(sampleRate).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })

        // data subchunk
        data.append(contentsOf: "data".utf8)
        data.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Array($0) })

        // PCM bytes
        for s in samples {
            data.append(contentsOf: withUnsafeBytes(of: s.littleEndian) { Array($0) })
        }

        return data
    }
}
