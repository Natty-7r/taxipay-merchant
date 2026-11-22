# Taxi Pay Merchant (Flutter)

The app taxi operators use to run their business on Taxi Pay. Merchants have no website, so this app is their only way in (see `../PRD.md`). It talks only to `taxi-pay-api`.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   # API on this machine, Android emulator
```

- `API_BASE_URL` defaults to `http://10.0.2.2:8080`. Debug builds may use plain http; release builds need https.
- `LOG_HTTP=false` turns off the HTTP request log in debug builds. Request and response bodies are never logged.

## What it does

| Area | Screens |
|---|---|
| Account | Login (merchant accounts only), two-step business registration, forced password change |
| Approval gate | Pending, rejected or suspended businesses see their status and the admin's reason, upload documents and resubmit |
| Home | Revenue, passengers, completed trips, active taxis, taxis on the road, unread badge |
| Operate | Start an operation (taxi, assigned route, driver). Live taxi screen with a seat map: tap to mark seats occupied or free; paid seats turn green with their destination, refreshed every 10 s. Depart, arrive (optionally opening the return trip), open the next trip, finish |
| Fleet | Taxis (add with a seat template, layout preview, share the QR code PNG to print), drivers, routes (stops, submit for approval, journeys with official fares, assign taxis) |
| Payments | Passenger payments, filtered by status |
| More | Notifications inbox, Connect Telegram (one-time t.me link), language (English / Amharic), offers opt-in, logout |

## Structure

```
lib/
├── core/                 shared by every feature
│   ├── config/           Env (--dart-define)
│   ├── network/          ApiClient (Dio): envelope unwrapping, ApiException, bearer token,
│   │                     X-Request-Id trace id, refresh-token rotation on 401
│   ├── storage/          tokens in Android Keystore / iOS Keychain
│   ├── router/           go_router + redirectFor(): splash → login → password → approval gate → app
│   ├── logging/          logger (warnings and errors only in release)
│   ├── theme/ widgets/ utils/
│   ├── locale.dart       app language (user preference, switchable)
│   └── localization.dart delegates (material_ui, see the note there)
├── features/<feature>/
│   ├── data/             <feature>_api.dart (endpoints) + models (fromJson factories = mappers)
│   └── presentation/     Riverpod providers / controllers + screens
└── l10n/                 app_en.arb, app_am.arb → generated AppLocalizations
```

- **State:** Riverpod 3. Automatic retries are turned off, so a failed call shows an error with "Try again".
- **Errors:** every failure is an `ApiException` with the API's `errorCode`, message, details and `traceId`. The trace id is shown so support can find the request in the server logs.
- **Flutter 3.50:** Material comes from `package:material_ui` (`flutter/material.dart` is deprecated).

## Test

```bash
flutter analyze
flutter test
```

- **API client** (with a fake HTTP transport): envelope unwrapping, error mapping, token refresh with retry, sign-out when the refresh fails.
- **Router:** the redirect rules, including the approval gate.
- **Model mappers.**
- **Login screen:** a widget test, including Amharic.
