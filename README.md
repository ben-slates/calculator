# NearPay

NearPay is an offline-first peer-to-peer mobile wallet that supports encrypted payment transfer over BLE, with WiFi Direct, NFC, and QR as fallback transports.

## Monorepo Layout

- `mobile/`: Flutter app (Android/iOS)
- `backend/`: Django REST API + PostgreSQL + Redis sync pipeline

## MVP Features Implemented

### Mobile
- Riverpod-based state management and clean feature modules.
- Device keypair generation using secp256k1.
- Signed payment token creation with nonce + timestamp.
- AES-256-GCM payload encryption with ECDH-derived shared key.
- BLE transport abstraction with fallback transport strategy order.
- Offline wallet ledger stored in SQLite via Drift.
- Pending queue + sync orchestrator for eventual reconciliation.
- Merchant mode toggles unlimited offline accept policy and CSV export API.

### Backend
- Custom user model with phone + CNIC and merchant mode flag.
- Wallet + transaction models with replay-protection nonce uniqueness.
- JWT + OTP endpoints (OTP provider abstraction ready for Twilio).
- Sync API that verifies secp256k1 signature and rejects replay/double-spend.
- Basic fraud scoring based on velocity and failed verification events.

## Security Model

1. ECDSA secp256k1 keypair per device.
2. Private keys protected by OS secure hardware via secure storage wrapper.
3. Payment token fields: `sender_id`, `receiver_id`, `amount`, `timestamp`, `nonce`, `signature`.
4. Token signed by sender.
5. Encrypted envelope uses AES-256-GCM with ECDH-derived key.
6. Receiver verifies signature and timestamp/nonce anti-replay rules.

## Setup

### Mobile
```bash
cd mobile
flutter pub get
flutter test
```

### Backend
```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
pytest
```

## API Overview

- `POST /api/auth/signup/`
- `POST /api/auth/request-otp/`
- `POST /api/auth/verify-otp/`
- `GET /api/wallet/balance/`
- `POST /api/sync/transactions/`
- `GET /api/transactions/history/`
- `POST /api/transactions/verify/`

## Offline Transaction Flow

1. Sender enters amount + recipient.
2. App creates `PaymentToken` and signs it.
3. Transport manager attempts BLE first.
4. Receiver decrypts, validates signature + freshness, and records receipt.
5. Both wallets updated locally and transaction queued for sync.
6. Sync engine uploads pending transactions when online.

## Development Phases

- **Phase 1:** BLE, crypto signing, local wallet, offline send/receive (implemented).
- **Phase 2:** Sync reconciliation, anomaly checks, merchant mode (implemented).
- **Phase 3:** WiFi Direct + NFC concrete adapters and scale hardening (interfaces + stubs included).
