# The Groves — Inclusive Tax Calculator (Flutter + Firebase)

A production-quality Flutter application that reverse-calculates tax breakdowns from **inclusive retail prices** (final price paid by the customer, including taxes). Built to support Saudi Arabia’s common item categories:

- **Regular items:** 15% VAT only  
- **Tobacco products:** 100% excise tax on base + 15% VAT applied to (base + excise)

The app supports adding multiple mixed items, displays per-item breakdowns, computes accurate grand totals, provides local persistence, and includes **optional cross-device history sync** using Firebase Authentication + Firestore.

---

## Features

### Core
- Add items by **inclusive price** with validation
- Select item type: **Regular** / **Tobacco**
- Per-item breakdown: **Base / Excise / VAT / Total Tax**
- Grand totals: **Inclusive / Base / Excise / VAT / Total Tax**
- Clear / reset cart
- Dark mode support (Material 3)

### Persistence
- Local persistence using **Hive**
  - Cart persistence
  - History persistence
  - Settings persistence (currency, rates, theme mode)

### Bonus / Highly Valued All DONE
- **History screen** with history detail view
- **Configurable tax rates** in Settings
- Pie chart visualization of totals breakdown (fl_chart)
- **Firebase Auth + Firestore sync** for history across devices
- Unit tests for tax calculation logic

---

## Tax formulas (must be accurate)

### Regular item (15% VAT)
Given inclusive price **P**:

- Base = P ÷ 1.15
- VAT = P − Base

### Tobacco item (100% excise + VAT on base+excise)
Excise is 100% of base, and VAT is applied to (base + excise).

- Total multiplier (in this implementation): configurable in Settings (default **2.30** for assessment)
- Base = P ÷ multiplier
- Excise = Base × 1.00
- VAT = (Base + Excise) × 0.15
- Total tax = Excise + VAT
- Inclusive = Base + Excise + VAT = P

> Note: Rates and tobacco multiplier are configurable via Settings for flexibility.

---

## Architecture

- Flutter + Material 3 UI
- Riverpod state management (Notifier + Providers)
- Clean separation by feature:
  - `domain/` models & services (pure logic)
  - `data/` local persistence repositories (Hive) + remote store (Firestore)
  - `presentation/` screens, widgets, providers

The tax calculator logic is isolated in the domain layer and covered by unit tests.

---

## Setup (Local)

### Prerequisites
- Flutter **3.38.x**
- Dart **3.10.x**
- Android Studio (for emulator)
- Firebase CLI + FlutterFire CLI (for Firebase integration)

### Install dependencies
-flutter pub get 

### Run analyzer + tests
-flutter analyze
-flutter test

### Run on Android emulator (List emulators)
-flutter emulators

### Launch (example):
-flutter emulators --launch Pixel_6
-flutter devices
-flutter run -d emulator-5554