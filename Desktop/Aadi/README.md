# COURAGE COMPUTER — REAL-WORLD RECREATION

> *"What if the Computer from Courage the Cowardly Dog actually existed as a modern, 100% offline local AI?"*

An original, fully functional, retro-futuristic AI terminal application built with **Swift**, **SwiftUI**, **Apple Vision**, and **AVFoundation**. Engineered from scratch without any external cloud APIs, dependencies, or copyrighted assets. Designed specifically to meet and exceed the constraints of the **Apple Swift Student Challenge**.

---

## ⚡ Key Highlights

* **100% Offline Hybrid Intelligence**: Operates completely detached from the internet. No OpenAI, Gemini, Claude, Ollama, or remote servers required.
* **Apple Vision Integration**: Uses Apple's native Vision framework (`VNClassifyImageRequest`, `VNRecognizeAnimalsRequest`, `VNDetectRectanglesRequest`) for real-time optical classification, accompanied by high-fidelity simulated sensor targets for Mac/Simulator testing.
* **Authentic CRT Aesthetic**: Custom SwiftUI shaders providing phosphor glow, dynamic scanlines, barrel distortion vignette, CRT flicker, typewriter text streaming, and blinking block cursor (`█`). Supports **Phosphor Green (P1)**, **Amber Monochrome (P3)**, and **Ghost Blue (P4)** CRT tubes.
* **Procedural Sound Engine**: Mathematically synthesizes vintage CRT degauss pops, high-voltage flyback transformer coil whine (15.7 kHz), relay clicks, teletype bursts, sonar pings, and warning buzzers directly into PCM audio in memory. **Zero external audio files needed (0 MB audio footprint).**
* **Mechanical Speech Synthesizer**: Tuned with `AVSpeechSynthesizer` for a distinctive robotic, sarcastic cadence.
* **Multimodal Investigation Mode**: Correlates Optical feeds, Acoustic decibel levels, Ambient Lux, Motion variance, and Memory history to produce structured paranormal deductions and tactical advisories.
* **Local Persistent Memory Bank**: Searchable, categorizable solid-state memory store with natural language retrieval (*"Have you seen this before?"* -> *"Yes. You showed it to me earlier at 14:12."*).
* **Ultra-Lightweight Package**: Entire application package is under **500 KB** (well within the 15–20 MB target and under the 25 MB Apple Student Challenge limit).

---

## 📐 System Architecture

```text
                  USER
                   │
         ┌─────────┼─────────┐
         ↓         ↓         ↓
       VOICE      TEXT      CAMERA
         │         │         │
         ↓         ↓         ↓
      Speech     Intent    Vision
      Engine     Engine    Engine
         │         │         │
         └─────────┼─────────┘
                   ↓
            CONTEXT ENGINE
                   ↓
            MEMORY MANAGER
                   ↓
           REASONING ENGINE
                   ↓
         PERSONALITY ENGINE
                   ↓
          RESPONSE GENERATOR
                   ↓
            TEXT + SPEECH
```

### Core Components

1. **`ComputerPersonalityEngine`**:
   - Generates original dry, sarcastic, analytical, and occasionally ominous dialogue in the authentic spirit of the fictional Computer.
   - Never cheerful or generic. Delivers memorable dry punchlines, calculated warnings, and condescending technological superiority.

2. **`ReasoningEngine`**:
   - Deterministic multi-factor inference engine.
   - Correlates: `Object Taxonomy + Acoustic Decibels + Photonic Lux + Kinetic Motion + Historical Recurrence + Witching Hour Peak`.
   - Produces threat ratings (`NOMINAL`, `LOW`, `ELEVATED`, `HIGH`, `CRITICAL`), anomaly probabilities, primary deductions, and actionable recommendations.

3. **`ComputerIntelligenceEngine`**:
   - 100% offline Intent Classifier and NLU pipeline.
   - Maps inputs to intents: `greeting`, `question`, `visionQuery`, `objectQuery`, `memoryQuery`, `investigation`, `systemStatus`, `threatCheck`, `philosophical`, `help`, `unknown`.
   - Extracts semantic slots and context.

4. **`VisionManager`**:
   - Live camera capture feed using AVFoundation.
   - Apple Vision framework image analysis + automated lux estimation.
   - 6 built-in simulated test targets (*"Black Feline (Cat)"*, *"Ancient Cursed Urn"*, *"Ticking Brown Parcel"*, *"Shadow Entity at Windmill"*, *"Ceramic Teacup"*, *"Unsettling Wooden Mask"*).

5. **`SoundSynthesizer`**:
   - Pure mathematical PCM/WAV synthesizer producing procedural retro audio effects in real time.

6. **`MemoryManager`**:
   - Local persistent register storing structured `MemoryEntry` records.
   - Queryable via natural language and interactive CRT memory browser.

---

## 🖥️ Screen Overview

| Screen | Description |
| :--- | :--- |
| **Boot Sequence** | Authentic CRT hardware self-test, memory check, phosphor flash, and ASCII banner. |
| **Main Console** | Terminal transcript, status badges (`[AUDIO] [VISION] [MEMORY] [LOCAL AI]`), quick query pills, command line, and speech mic. |
| **Vision HUD** | Viewfinder with crosshair reticle, corner brackets, scanning laser line, optical telemetry, and target selector. |
| **Investigate Mode** | 4-channel multimodal sensor deck (Optical, Audio dB, Lux, Memory) with real-time correlation progress and diagnostic report. |
| **Memory Bank** | Searchable timeline of past encounters, threat badges, category filters, and detail inspection sheet. |
| **Diagnostics** | Hardware health status (*"NETWORK: DISCONNECTED. GOOD. I PREFER TO BE ALONE."*), tube color switcher, speech pitch/rate controls. |

---

## 🚀 How to Run

### Option 1: macOS Executable (Command Line)
```bash
# Build and run directly on macOS
swift run
```

### Option 2: Xcode (macOS or iOS/iPadOS)
1. Open the project root folder in Xcode:
   ```bash
   xed .
   ```
2. Select the `CourageComputer` target.
3. Choose your target destination (**My Mac**, **iPad Simulator**, or **iPhone Simulator**).
4. Press **⌘R** to Run.

### Option 3: Swift Playgrounds (`.swiftpm`)
The project includes a ready-to-submit standalone Swift Playgrounds package:
- Directory: `CourageComputer.swiftpm`
- Double click or transfer `CourageComputer.swiftpm` to an iPad or Mac running **Swift Playgrounds 4+**.
- Tap **Play** to run immediately.

---

## 🧪 Running the Test Suite

A comprehensive test suite is included in `Tests/CourageComputerTests`:
```bash
swift test
```
Verifies intent classification, deterministic reasoning rules, memory persistence, personality formatting, and procedural sound buffer synthesis.

---

## 🛡️ Originality & Licensing Notice

This software is an independent creative recreation inspired by the concept of an old CRT computer with dry artificial intelligence. All source code, procedural sound synthesizers, UI components, dialogue trees, reasoning algorithms, and ASCII visual designs are original works created specifically for this project. No copyrighted audio files, screenshots, video assets, or television dialogue are included or redistributed.
