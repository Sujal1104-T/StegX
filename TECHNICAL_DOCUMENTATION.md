# StegX - Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Core Components](#core-components)
4. [Security Implementation](#security-implementation)
5. [UI/UX Design](#uiux-design)
6. [Data Flow](#data-flow)
7. [Technical Specifications](#technical-specifications)

---

## Project Overview

**StegX** is a cross-platform steganography application built with Flutter that combines advanced cryptography with pixel-level image manipulation to securely hide encrypted messages within images. The application features a cyberpunk-themed interface and integrates Firebase for authentication and history tracking.

### Key Features
- **AES-GCM Encryption**: Military-grade encryption before steganographic embedding
- **Randomized LSB Steganography**: Uses pseudo-random pixel selection for enhanced security
- **Firebase Integration**: User authentication and cloud-based history tracking
- **Cross-Platform**: Supports Android, iOS, Web, Windows, macOS, and Linux
- **Cyberpunk UI**: Immersive dark-mode interface with neon aesthetics and animations

---

## Architecture

### Project Structure
```
lib/
├── core/
│   └── utils/
│       └── portable_random.dart          # Cross-platform PRNG implementation
├── data/
│   ├── models/
│   │   ├── history_entry.dart           # Data model for encryption/decryption history
│   │   └── user_settings.dart           # User preferences model
│   ├── auth_service.dart                # Firebase authentication logic
│   ├── crypto_service.dart              # AES encryption/decryption
│   ├── stego_service.dart               # Steganography embedding/extraction
│   ├── history_service.dart             # Firestore history management
│   └── settings_service.dart            # User settings persistence
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart           # Initial loading screen
│   │   ├── login_screen.dart            # Firebase authentication UI
│   │   ├── home_screen.dart             # Main navigation hub
│   │   ├── encrypt_screen.dart          # Message encryption & embedding UI
│   │   ├── decrypt_screen.dart          # Message extraction & decryption UI
│   │   ├── history_screen.dart          # Operation history viewer
│   │   ├── settings_screen.dart         # User preferences
│   │   └── help_screen.dart             # User guide and documentation
│   ├── providers/                       # Riverpod state management
│   ├── widgets/                         # Reusable UI components
│   └── theme/
│       └── theme.dart                   # Cyberpunk theme configuration
├── firebase_options.dart                # Firebase configuration
└── main.dart                            # Application entry point
```

### Technology Stack
- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod 2.5.1
- **Backend**: Firebase (Auth, Firestore)
- **Encryption**: AES-GCM (encrypt package 5.0.3)
- **Image Processing**: image package 4.1.7
- **Cryptographic Hashing**: crypto package 3.0.3
- **UI Enhancements**: flutter_animate, google_fonts
- **Storage**: SharedPreferences, path_provider

---

## Core Components

### 1. Cryptography Service (`crypto_service.dart`)

#### Purpose
Handles all encryption and decryption operations using AES-GCM (Galois/Counter Mode) for authenticated encryption.

#### Key Methods

**`generateKey({int length = 8})`**
- Generates a user-friendly 8-character key using Base58-like character set
- Avoids ambiguous characters (0/O, 1/I/l)
- Uses `Random.secure()` for cryptographically secure randomness

**`hashKey(String key)`**
- Creates SHA-256 hash of the key for secure storage/verification
- Used for key validation without storing plaintext keys

**`encrypt({required String plainText, required String key})`**
- Encrypts plaintext using AES-GCM with 256-bit key
- Generates random 16-byte IV (Initialization Vector) for each encryption
- Returns format: `IV(base64):CipherText(base64)`
- Ensures semantic security (same message encrypted twice produces different outputs)

**`decrypt({required String encryptedData, required String key})`**
- Decrypts data by splitting IV and ciphertext
- Validates authenticity using GCM authentication tag
- Throws exception on invalid key or corrupted data

**`_processKey(String key)`** (Private)
- Converts user-friendly keys to 32-byte AES keys
- Uses SHA-256 hashing to derive key material
- Supports both short keys and legacy base64 keys

#### Security Features
- **AES-GCM**: Provides both confidentiality and authenticity
- **Random IVs**: Prevents pattern analysis
- **Key Derivation**: SHA-256 ensures consistent 256-bit keys
- **Secure RNG**: Uses platform-specific secure random generators

---

### 2. Steganography Service (`stego_service.dart`)

#### Purpose
Implements a randomized Least Significant Bit (LSB) steganography algorithm to hide encrypted data within image pixels.

#### Algorithm Overview

**Embedding Process:**
1. **Payload Preparation**: Combines 32-bit length header with secret data
2. **Capacity Validation**: Ensures image can hold the data (3 bits per pixel)
3. **PRNG Initialization**: Seeds pseudo-random generator with SHA-256 hash of key
4. **Random Pixel Selection**: Uses PRNG to select non-repeating pixels
5. **LSB Embedding**: Modifies least significant bit of R, G, B channels
6. **PNG Encoding**: Saves as lossless PNG to preserve embedded data

**Extraction Process:**
1. **PRNG Synchronization**: Uses same key to regenerate pixel sequence
2. **Header Extraction**: Reads first 32 bits to determine payload length
3. **Data Extraction**: Reads LSBs from randomized pixels
4. **Validation**: Checks for reasonable data length (< 50MB)
5. **Reconstruction**: Converts bits back to original message

#### Key Methods

**`embedData({required img.Image image, required String secretData, required String key})`**
- Embeds encrypted data into image using randomized LSB
- Returns PNG-encoded image bytes
- Throws exception if image capacity insufficient
- Uses collision detection to prevent pixel reuse

**`extractData({required Uint8List imageBytes, required String key})`**
- Extracts hidden data using key-synchronized PRNG
- Validates data length header for corruption detection
- Returns decrypted message string

**`_getStableSeed(String key)`** (Private)
- Generates deterministic 32-bit seed from key using SHA-256
- Ensures same key produces same pixel sequence
- Critical for extraction to match embedding order

#### Security Features
- **Randomized Embedding**: Prevents visual pattern detection
- **Key-Dependent Sequence**: Different keys produce different pixel patterns
- **Capacity Limits**: Prevents performance degradation (max 50% image capacity)
- **Lossless Format**: Requires PNG to preserve LSB modifications
- **Collision Detection**: Prevents data corruption from pixel reuse

#### Performance Optimizations
- **Isolate Support**: Top-level functions for background processing
- **Safety Timeouts**: Prevents infinite loops in high-density scenarios
- **Set-Based Tracking**: Efficient duplicate pixel detection

---

### 3. Authentication Service (`auth_service.dart`)

#### Purpose
Manages Firebase Authentication for user login, registration, and session management.

#### Key Features
- **Email/Password Authentication**: Standard Firebase auth
- **Anonymous Sign-In**: Optional guest mode
- **Session Persistence**: Automatic token refresh
- **Auth State Streaming**: Real-time authentication status

#### Integration
- Uses Riverpod's `authStateProvider` for reactive UI updates
- `AuthGuard` widget protects routes requiring authentication
- Redirects unauthenticated users to login screen

---

### 4. History Service (`history_service.dart`)

#### Purpose
Tracks encryption and decryption operations in Cloud Firestore for audit trail and user convenience.

#### Data Model
```dart
class HistoryEntry {
  String id;
  String userId;
  String operation;      // "encrypt" or "decrypt"
  String fileName;
  DateTime timestamp;
  String? keyHash;       // SHA-256 hash of key (never plaintext)
}
```

#### Features
- **Cloud Sync**: Accessible across devices
- **Privacy**: Stores key hashes, not actual keys
- **Filtering**: Query by user, operation type, date range
- **Deletion**: User can clear history

---

### 5. Settings Service (`settings_service.dart`)

#### Purpose
Manages user preferences using SharedPreferences for local storage.

#### Configurable Settings
- **Theme**: Dark mode, accent colors
- **Default Key Length**: 8-32 characters
- **Auto-Save**: Automatically save encrypted images
- **Compression**: Image quality settings
- **Notifications**: Operation completion alerts

---

## Security Implementation

### Multi-Layer Security Model

#### Layer 1: Encryption (Confidentiality)
- **Algorithm**: AES-256-GCM
- **Key Size**: 256 bits (derived from user key via SHA-256)
- **Mode**: GCM (Galois/Counter Mode) for authenticated encryption
- **IV**: 16 bytes, randomly generated per encryption

#### Layer 2: Steganography (Obfuscation)
- **Method**: Randomized LSB embedding
- **Channels**: RGB (3 bits per pixel)
- **Randomization**: Key-seeded PRNG for pixel selection
- **Format**: PNG (lossless to preserve LSB data)

#### Layer 3: Authentication (Integrity)
- **GCM Tag**: Automatic authentication tag validation
- **Key Hashing**: SHA-256 for key verification
- **Length Header**: Detects truncation/corruption

### Security Best Practices
1. **Never Store Plaintext Keys**: Only SHA-256 hashes in history
2. **Random IVs**: Each encryption uses unique IV
3. **Secure RNG**: Platform-specific secure random generators
4. **Lossless Storage**: Always use PNG for stego images
5. **Input Validation**: Sanitize all user inputs
6. **Error Handling**: Generic error messages to prevent information leakage

### Threat Model
- **Protects Against**:
  - Casual visual inspection
  - Statistical steganalysis (randomized embedding)
  - Brute force attacks (AES-256 + key derivation)
  - Man-in-the-middle (encrypted before embedding)
  
- **Does NOT Protect Against**:
  - Targeted forensic analysis with known algorithm
  - Quantum computing attacks (future threat)
  - Compromised device/key storage
  - Social engineering

---

## UI/UX Design

### Design Philosophy
**Cyberpunk Aesthetic**: Dark backgrounds, neon accents, glitch effects, and futuristic typography create an immersive experience.

### Theme Configuration (`theme.dart`)
- **Primary Color**: Neon cyan (#00FFFF)
- **Accent Color**: Electric purple (#9D00FF)
- **Background**: Deep black (#0A0A0A)
- **Typography**: Google Fonts (Orbitron, Rajdhani)
- **Animations**: flutter_animate for smooth transitions

### Screen Breakdown

#### 1. Splash Screen
- Animated logo with glitch effect
- Firebase initialization
- Auto-navigation to login/home

#### 2. Login Screen
- Email/password fields with cyberpunk styling
- Firebase authentication integration
- Error handling with animated feedback
- Guest mode option

#### 3. Home Screen
- Navigation hub with 4 primary actions:
  - Encrypt Message
  - Decrypt Message
  - View History
  - Settings
- Quick stats dashboard
- Recent activity preview

#### 4. Encrypt Screen
- **Step 1**: Select cover image (image_picker)
- **Step 2**: Enter secret message
- **Step 3**: Generate/enter encryption key
- **Step 4**: Preview and save encrypted image
- Real-time capacity indicator
- Key strength meter

#### 5. Decrypt Screen
- **Step 1**: Select stego image
- **Step 2**: Enter decryption key
- **Step 3**: View extracted message
- Copy to clipboard functionality
- Error handling for wrong keys

#### 6. History Screen
- Chronological list of operations
- Filter by encrypt/decrypt
- Search by filename
- Swipe to delete entries
- Cloud sync indicator

#### 7. Settings Screen
- User profile management
- Theme customization
- Default key length
- Auto-save preferences
- Clear cache/history

#### 8. Help Screen
- Step-by-step tutorials
- Security best practices
- FAQ section
- Technical documentation link

---

## Data Flow

### Encryption Flow
```
User Input (Message) 
  → CryptoService.encrypt() 
  → AES-GCM Encryption 
  → Encrypted Data (IV:CipherText)
  → User Selects Image
  → StegoService.embedData()
  → Randomized LSB Embedding
  → PNG Encoding
  → Save to Device
  → HistoryService.addEntry()
  → Cloud Firestore
```

### Decryption Flow
```
User Selects Stego Image
  → StegoService.extractData()
  → LSB Extraction (Key-Synchronized PRNG)
  → Encrypted Data (IV:CipherText)
  → CryptoService.decrypt()
  → AES-GCM Decryption
  → Plaintext Message
  → Display to User
  → HistoryService.addEntry()
  → Cloud Firestore
```

### Authentication Flow
```
User Login
  → AuthService.signIn()
  → Firebase Authentication
  → Auth Token
  → authStateProvider (Riverpod)
  → UI Updates (AuthGuard)
  → Navigate to Home
```

---

## Technical Specifications

### Performance Metrics
- **Encryption Speed**: ~1ms per 1KB message (AES-GCM)
- **Embedding Speed**: ~500ms for 1920x1080 image with 1KB payload
- **Extraction Speed**: ~400ms for 1920x1080 image
- **Max Payload**: 50% of image capacity (safety limit)
- **Supported Image Formats**: JPEG, PNG, BMP (input), PNG (output)

### Platform Support
- **Android**: API 21+ (Android 5.0 Lollipop)
- **iOS**: iOS 12+
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+

### Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | 2.5.1 | State management |
| image | 4.1.7 | Image processing |
| encrypt | 5.0.3 | AES encryption |
| crypto | 3.0.3 | Hashing (SHA-256) |
| firebase_core | 4.4.0 | Firebase initialization |
| firebase_auth | 6.1.4 | User authentication |
| cloud_firestore | 6.1.2 | Cloud database |
| image_picker | 1.1.1 | Image selection |
| file_saver | 0.2.0 | File saving |
| permission_handler | 11.3.1 | Storage permissions |
| flutter_animate | 4.5.0 | UI animations |
| google_fonts | 6.2.1 | Custom typography |

### Build Configuration
- **Min SDK (Android)**: 21
- **Target SDK (Android)**: 34
- **iOS Deployment Target**: 12.0
- **Flutter SDK**: 3.9.2+
- **Dart SDK**: 3.9.2+

### Firebase Configuration
- **Authentication**: Email/Password, Anonymous
- **Firestore**: User history collection
- **Security Rules**: User-specific read/write access
- **Offline Persistence**: Enabled for Firestore

### Storage Requirements
- **App Size**: ~25MB (Android APK)
- **Cache**: ~10MB (image processing)
- **User Data**: ~1KB per history entry

---

## Development Notes

### Testing Strategy
1. **Unit Tests**: Crypto and stego algorithms
2. **Widget Tests**: UI components
3. **Integration Tests**: End-to-end encryption/decryption
4. **Manual Testing**: Cross-platform compatibility

### Known Limitations
1. **Image Format**: Output must be PNG (lossless)
2. **Capacity**: Limited by image size (3 bits per pixel)
3. **Performance**: Large images may cause UI lag (use isolates)
4. **Compression**: JPEG compression destroys embedded data

### Future Enhancements
- [ ] Support for video steganography
- [ ] Multi-file encryption
- [ ] Blockchain-based key exchange
- [ ] Advanced steganalysis resistance
- [ ] Biometric authentication
- [ ] End-to-end encrypted cloud storage

---

## License & Security Disclaimer

**READ-ONLY ACCESS**: This code is for demonstration purposes only. Copying, modifying, reusing, or distributing without permission is prohibited.

**Security Warning**: While StegX implements industry-standard encryption and steganography techniques, no system is 100% secure. This application should not be used for highly sensitive or classified information. Always follow best practices for key management and secure communication.

---

*Last Updated: February 2, 2026*
