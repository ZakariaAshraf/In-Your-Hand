# In Your Hand — بين إيديك

> A smart business management app for small business owners in Egypt.  
> تطبيق إدارة أعمال ذكي لأصحاب المشاريع الصغيرة في مصر.

---

## What Is This App?

**In Your Hand** helps small business owners track what clients owe them. Instead of writing debts in a notebook or trying to remember who paid and who didn't, everything is in one place — clients, orders, payments, and reports — accessible from your phone at any time.

The app was built specifically for the Egyptian market, supports both Arabic and English, and works entirely through a simple mobile interface.

---

## Why Is It Different?

Most accounting apps are built for accountants. This one is built for the shop owner, the contractor, the supplier — anyone who sells on credit and needs to know, right now, who owes them money and how much.

| Feature | What makes it different |
|---|---|
| Voice Orders | Speak an order in Arabic or English — AI parses it into a structured order automatically |
| WhatsApp Reminders | Send a payment reminder directly to a client's WhatsApp with one tap |
| PDF Reports | Generate a professional PDF for any order or client and print or share it instantly |
| Arabic-first | Full RTL support, Arabic UI, Cairo font in PDFs |
| Offline awareness | Shows a banner when the connection drops — no silent failures |
| Simple, not bloated | No inventory, no invoicing, no tax — just clients, orders, and money owed |

---

## App Phases — From First Version to Now

### Phase 1 — Core Foundation
- Firebase Auth (sign in / sign up)
- Basic client management (add, edit, soft delete)
- Basic order management (add, view, delete)
- Firestore as the backend database
- Bottom navigation with 4 tabs: Home, Orders, Clients, Settings

### Phase 2 — Financial Tracking
- Payment history per order (add partial payments, track over time)
- Order status calculated automatically: **Pending → Partial → Paid**
- Total unpaid amount per client
- Dashboard screen with financial summary cards:
  - Total amount across all orders
  - Total paid
  - Total unpaid
  - Clients with outstanding debt
- WhatsApp reminder button on order details (pre-filled message with the amount owed)

### Phase 3 — UX & Polish
- Arabic + English localization (full l10n with ARB files)
- Dark mode and light mode with persistent preference
- Language toggle (Arabic / English) with persistent preference
- Responsive sizing utility (`ScreenUtil`) — works across phone sizes
- Connectivity overlay — offline banner shown automatically
- Searchable client list with real-time filtering
- Order filter tabs (All / Pending / Partial / Paid)
- Client details screen showing all orders for that client with totals
- Bottom nav bar hidden on detail screens (`withNavBar: false`)

### Phase 4 — Voice Orders (AI Feature)
- Speech-to-text using the device microphone
- Supports Arabic (`ar_EG`) and English (`en_US`) recognition
- Gemini AI parses the spoken text and extracts:
  - Client name (matched against existing clients)
  - Order description
  - Total amount
  - Paid amount
- Editable confirmation dialog — user can correct any field before saving
- Graceful fallback when microphone permission is denied or Gemini is not configured

### Phase 5 — PDF Reports & Printing
- **Order PDF**: client info, order description, financial summary (total / paid / remaining), notes, full payment history table
- **Client PDF**: client profile, summary tiles (total orders, total amount, paid, unpaid), full orders table
- Cairo font embedded in all PDFs — Arabic text renders correctly
- RTL layout in PDFs when app is in Arabic
- Two actions per report:
  - **Print icon** → opens native system print dialog directly (no preview)
  - **PDF icon** → opens a preview screen with share/download options

---

## Screens Overview

| Screen | Purpose |
|---|---|
| Sign In / Sign Up | Firebase email authentication |
| Choose Character | Avatar selection during registration |
| Home | Quick summary + shortcuts to add order/client |
| Orders | Full order list with status filter tabs |
| Add Order | Form with client picker, description, amounts; voice shortcut |
| Order Details | Payments, notes, WhatsApp reminder, print/share PDF, delete |
| Clients | Searchable client list |
| Add / Edit Client | Client form (name, phone, notes) |
| Client Details | Client profile + all their orders + print/share PDF |
| Dashboard | Financial overview with 5 summary cards |
| Settings | Profile, theme, language, change password, logout |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth + Firestore) |
| State Management | BLoC / Cubit (flutter_bloc) + Riverpod (theme & locale) |
| Local Storage | SharedPreferences |
| AI | Google Gemini (google_generative_ai) |
| Speech | speech_to_text |
| PDF | pdf + printing |
| Navigation | persistent_bottom_nav_bar |
| Connectivity | connectivity_plus |
| Deep Links | url_launcher (WhatsApp) |
| Localization | Flutter l10n (ARB files) — Arabic + English |
| Font | Cairo TTF (Arabic/Latin) |

---

## Project Structure

```
lib/
├── core/
│   ├── cache/          # SharedPreferences helper
│   ├── config/         # API keys (app_keys.dart — not committed)
│   ├── generated/      # Extensions (date formatting, etc.)
│   ├── locale/         # Language provider (Riverpod)
│   ├── services/       # GeminiService (AI parsing)
│   ├── themes/         # Theme provider, text theme
│   ├── utils/          # AppColors, ScreenUtil, PdfManager
│   └── widgets/        # Shared widgets (CustomTextField, CustomButton, etc.)
├── features/
│   ├── authenticate/   # Sign in, sign up, auth cubit
│   ├── clients/        # Client CRUD, details, PDF
│   ├── dashboard/      # Financial summary
│   ├── home/           # Home screen
│   ├── orders/         # Order CRUD, payments, details, PDF
│   ├── settings/       # Profile, theme, language
│   └── voice_order/    # Speech → AI → order
├── l10n/               # ARB files + generated localizations
└── main.dart
```

---

## Setup & Running

### Prerequisites
- Flutter SDK `^3.8.1`
- Firebase project with Auth and Firestore enabled
- (Optional) Google Gemini API key for voice orders

### Steps

```bash
# 1. Clone the repo
git clone <repo-url>
cd in_your_hand

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# Add your google-services.json (Android) and GoogleService-Info.plist (iOS)
# to the respective platform folders

# 4. Configure API keys
cp lib/core/config/app_keys.example.dart lib/core/config/app_keys.dart
# Edit app_keys.dart and add your Gemini API key

# 5. Run
flutter run
```

### Build for release (Android)

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

---

## Known Limitations (Pre-Deploy Notes)

- Voice order feature requires a Gemini API key — the app works fully without it, the mic button is hidden when not configured
- Help & Support screen is a placeholder (not yet implemented)
- No onboarding flow — users land directly on sign in
- PDF generation uses the Cairo font for Arabic — Firestore order IDs in PDFs are always LTR regardless of locale

---

## License

Private — all rights reserved.
