#  Extracta  
**Capture once. Understand instantly.**

---

##  Overview

Extracta is an experimental iOS app built with SwiftUI that reimagines how we interact with screenshots.

Instead of storing static images, Extracta turns screenshots into **interactive, actionable information** — extracting tasks, reminders, and key data directly from the image.

> Sweep across a screenshot, and the important information rises from it.

---

## Key Features

-  **On-device OCR (offline-first)**  
  Extracts text using Apple Vision framework — no internet required.

-  **Smart parsing**  
  Identifies tasks, dates, and contextual information using Natural Language processing.

-  **Signature Sweep Interaction**  
  A unique gesture-based interaction that reveals structured data from screenshots.

-  **Interactive Chips**  
  Extracted elements appear as actionable UI components:
  - Add reminders  
  - Create tasks  
  - Save notes  

-  **Hybrid Intelligence System**  
  Designed to never fail:
  - Auto-detection when possible  
  - Manual input when needed  

-  **Fully Offline**  
  No APIs. No data leaves the device.

---

##  Tech Stack

- SwiftUI  
- Vision Framework (OCR)  
- NaturalLanguage Framework  
- EventKit (Reminders)  
- MVVM Architecture  

---

##  Architecture

The project follows a clean **MVVM structure**:

Extracta/
├── App/
├── Models/
├── ViewModels/
├── Views/
├── Services/
├── Resources/

--- 


### Structure Explanation

- **Models** → Data structures  
- **ViewModels** → Business logic & state management  
- **Views** → UI rendering (SwiftUI)  
- **Services** → OCR, parsing, and system integrations  

---

## 🎯 How It Works

1. Load a screenshot  
2. Sweep across the screen  
3. Extracted elements appear as chips  
4. Interact with chips to create actions  

---

## 🧪 Demo Mode

To ensure reliability, Extracta includes:

- **Demo Mode** → Preloaded screenshots with instant results  
- **Live Mode** → Real OCR + parsing  

---

## ⚠️ Real-World Handling

Extracta is designed for imperfect inputs:

- Chat messages → Suggest context (event, reminder, etc.)  
- Partial text → Allow manual correction  
- Complex images → Fallback to note-saving  
- OCR uncertainty → Confidence-based UI  

---

## 📸 Screenshots

> Pending...

---

## 🎥 Demo

> Pending...

---

## 🧠 Why Extracta?

Most apps treat screenshots as static storage.  
Extracta treats them as **latent information waiting to be unlocked**.

It’s not about perfect AI —  
it’s about **augmenting human intent with intelligent assistance**.

---

## 📌 Status

🚧 In active development (SwiftUI App Playground project)

---

## 🤝 Contribution

This is a solo experimental project focused on interaction design and on-device intelligence.

---

## 🏁 Goal

To build a **fast, offline, intuitive system** that turns everyday screenshots into meaningful actions — without relying on cloud intelligence.

---


