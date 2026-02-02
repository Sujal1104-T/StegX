# StegX 🔐

<div align="center">

**A Cyberpunk-Themed Steganography Application**

*Hide encrypted messages within images using military-grade cryptography and advanced pixel manipulation*

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

</div>

---

## 🌟 Overview

**StegX** combines **AES-256-GCM encryption** with **randomized LSB steganography** to securely hide messages within images. The application features a stunning cyberpunk-themed interface and supports cross-platform deployment on Android, iOS, Web, Windows, macOS, and Linux.

### ✨ Key Features

- 🔒 **Military-Grade Encryption**: AES-256-GCM with authenticated encryption
- 🎨 **Randomized Steganography**: Key-seeded PRNG for enhanced security
- 🌐 **Cross-Platform**: Single codebase for all major platforms
- 🎭 **Cyberpunk UI**: Immersive dark-mode with neon aesthetics and animations
- 📊 **Cloud Sync**: Firebase integration for authentication and history tracking
- 🔑 **Smart Key Management**: User-friendly keys with SHA-256 derivation
- 📱 **Responsive Design**: Optimized for mobile, tablet, and desktop

---

## 🏗️ Architecture

### Technology Stack

| Component | Technology |
|-----------|-----------|
| **Framework** | Flutter 3.9.2+ |
| **Language** | Dart 3.9.2+ |
| **State Management** | Riverpod 2.5.1 |
| **Encryption** | AES-256-GCM (encrypt 5.0.3) |
| **Hashing** | SHA-256 (crypto 3.0.3) |
| **Image Processing** | image 4.1.7 |
| **Backend** | Firebase (Auth + Firestore) |
| **UI Animations** | flutter_animate 4.5.0 |
| **Typography** | Google Fonts (Orbitron, Rajdhani) |

### Core Components

1. **Crypto Service**: AES-256-GCM encryption with random IVs
2. **Stego Service**: Randomized LSB embedding with key-seeded PRNG
3. **Auth Service**: Firebase authentication and session management
4. **History Service**: Cloud-synced operation tracking
5. **Settings Service**: User preferences and configuration

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Firebase account (for authentication and cloud features)
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/StegX.git
   cd StegX
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Email/Password authentication
   - Create a Firestore database
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
     - Web: Update `firebase_options.dart`

4. **Run the app**
   ```bash
   # Android/iOS
   flutter run

   # Web
   flutter run -d chrome

   # Windows
   flutter run -d windows
   ```

---

## 📖 Usage

### Encrypting a Message

1. Navigate to **Encrypt** screen
2. Select a cover image (JPEG, PNG, BMP)
3. Enter your secret message
4. Generate or enter an encryption key
5. Save the encrypted image (PNG format)

### Decrypting a Message

1. Navigate to **Decrypt** screen
2. Select the stego image (PNG)
3. Enter the decryption key
4. View the extracted message

> **⚠️ Important**: Always use PNG format for stego images. JPEG compression will destroy embedded data.

---

## 🔐 Security

### Multi-Layer Security Model

1. **Encryption Layer**: AES-256-GCM with random IVs
2. **Steganography Layer**: Randomized LSB with key-seeded pixel selection
3. **Authentication Layer**: GCM authentication tags for integrity

### Security Features

- ✅ Cryptographically secure random number generation
- ✅ Key derivation using SHA-256
- ✅ No plaintext key storage (only hashes)
- ✅ Semantic security (same message → different outputs)
- ✅ Tamper detection via GCM authentication

### Threat Model

**Protects Against:**
- Casual visual inspection
- Statistical steganalysis (randomized embedding)
- Brute force attacks (AES-256 + key derivation)
- Man-in-the-middle attacks (encrypted before embedding)

**Does NOT Protect Against:**
- Targeted forensic analysis with known algorithm
- Quantum computing attacks (future threat)
- Compromised device/key storage

---

## 📚 Documentation

- **[Technical Documentation](TECHNICAL_DOCUMENTATION.md)**: Detailed architecture, algorithms, and implementation
- **[API Reference](docs/API.md)**: Service interfaces and methods *(coming soon)*
- **[Security Guide](docs/SECURITY.md)**: Best practices and threat model *(coming soon)*

---

## 🎨 Screenshots

*Coming soon: Cyberpunk UI screenshots*

---

## 🛠️ Development

### Project Structure

```
lib/
├── core/           # Utilities and helpers
├── data/           # Services and models
│   ├── models/     # Data models
│   └── *_service.dart
├── presentation/   # UI layer
│   ├── screens/    # App screens
│   ├── widgets/    # Reusable components
│   ├── providers/  # Riverpod state
│   └── theme/      # Cyberpunk theme
└── main.dart       # Entry point
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## ⚠️ Security Warning

This repository is for **demonstration and educational purposes only**. 

- API keys and Firebase configuration files are excluded for security
- To run locally, you must provide your own Firebase project
- Do not use for highly sensitive or classified information
- Always follow best practices for key management

---

## 📄 License

**READ-ONLY ACCESS**

Copying, modifying, reusing, or distributing any part of this code without explicit permission is **strictly prohibited**.

See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

This is a private demonstration project. Contributions are not accepted at this time.

---

## 📧 Contact

For inquiries, please contact the repository owner.

---

<div align="center">

**Made with ❤️ using Flutter**

*Secure. Invisible. Cyberpunk.*

</div>
