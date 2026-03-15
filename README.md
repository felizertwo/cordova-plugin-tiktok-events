# cordova-plugin-tiktok-events

Cordova Plugin für das TikTok Events SDK (iOS) – App Event Tracking & Attribution für TikTok Ads.

## Features

- ✅ TikTok Events SDK 1.6+ Integration
- ✅ App Tracking Transparency (ATT) Support
- ✅ SKAdNetwork Attribution
- ✅ Automatisches In-App Purchase Tracking
- ✅ Custom Event Tracking
- ✅ Advanced Matching (Email, Phone, etc.)

---

## Installation

```bash
cordova plugin add cordova-plugin-tiktok-events \
  --variable TIKTOK_ACCESS_TOKEN=dein_access_token \
  --variable TIKTOK_APP_ID=deine_app_id \
  --variable TIKTOK_TIKTOK_APP_ID=deine_tiktok_app_id
```

### Voraussetzungen

- Cordova iOS >= 6.0.0
- iOS >= 12.0
- TikTok for Business Account
- CocoaPods installiert

---

## Komplette Setup-Anleitung

### Schritt 1: TikTok Business Account einrichten

1. Geh zu [TikTok Ads Manager](https://ads.tiktok.com/)
2. Navigiere zu **Tools → Events**
3. Klick auf **App-Events verwalten**
4. Erstelle eine neue App oder wähle eine bestehende

### Schritt 2: IDs aus TikTok holen

Du brauchst 3 IDs:

| ID | Wo zu finden |
|----|--------------|
| **Access Token** | TikTok Ads Manager → Tools → Events → App auswählen → Einstellungen |
| **App ID** | TikTok Ads Manager → App-ID (z.B. `1234567890`) |
| **TikTok App ID** | TikTok Ads Manager → TikTok-App-ID (lange Nummer, z.B. `1234567890123456789`) |

### Schritt 3: Plugin installieren

```bash
cordova plugin add cordova-plugin-tiktok-events \
  --variable TIKTOK_ACCESS_TOKEN=DEIN_ACCESS_TOKEN \
  --variable TIKTOK_APP_ID=DEINE_APP_ID \
  --variable TIKTOK_TIKTOK_APP_ID=DEINE_TIKTOK_APP_ID
```

### Schritt 4: iOS Build

```bash
cordova build ios
```

Öffne das Projekt in Xcode und stelle sicher, dass CocoaPods die TikTokBusinessSDK Dependency installiert hat.

---

## Code-Integration

### SDK Initialisierung (einmalig beim App-Start)

```javascript
document.addEventListener('deviceready', function() {
  
  if (window.TikTokEvents) {
    TikTokEvents.initialize({
      debug: false  // true für Entwicklung, false für Production
    }, 
    function() {
      console.log('TikTok SDK ready');
    }, 
    function(error) {
      console.error('TikTok init failed:', error);
    });
  }
  
}, false);
```

### ATT-Dialog anzeigen (iOS 14+)

Der ATT-Dialog (App Tracking Transparency) fragt den User ob er Tracking erlaubt. **Wichtig:** Zeige ihn nicht sofort beim App-Start, sondern zu einem passenden Zeitpunkt (z.B. nach Login/Registrierung).

```javascript
// Nach Login oder Registrierung
if (window.TikTokEvents) {
  TikTokEvents.requestTrackingAuthorization(function(status) {
    console.log('ATT Status:', status);
    // status: 'authorized', 'denied', 'restricted', 'notDetermined'
  });
}
```

**Tipp:** iOS zeigt den Dialog nur einmal. Bei wiederholtem Aufruf wird nur der aktuelle Status zurückgegeben.

---

## Automatisches In-App Purchase Tracking

⚡ **Wichtig:** Das TikTok SDK trackt StoreKit-Käufe automatisch!

Du musst **NICHT** manuell `trackPurchase()` aufrufen für iOS In-App Purchases. Das SDK:

- Erkennt automatisch alle StoreKit-Transaktionen
- Feuert `Purchasing` wenn der Kauf-Dialog öffnet
- Feuert `Purchase` / `Kaufen` wenn der Kauf abgeschlossen ist
- Sendet Preis, Währung und Product-ID automatisch

### Was wird automatisch getrackt?

| Event | Beschreibung |
|-------|-------------|
| `Purchasing` | User startet Kaufprozess (StoreKit Dialog öffnet) |
| `Purchase` / `Kaufen` | Kauf erfolgreich abgeschlossen |
| `PurchaseFailed` | Kauf fehlgeschlagen/abgebrochen |

### Wann manuell tracken?

Nutze `trackPurchase()` nur für Käufe die **nicht** über StoreKit laufen (z.B. Web-Payments, externe Zahlungsanbieter).

---

## Manuelles Event Tracking

Für Custom Events die nicht automatisch getrackt werden:

```javascript
// Beliebiges Event
TikTokEvents.trackEvent('ViewContent', {
  content_id: 'artikel-123',
  content_type: 'product',
  value: 29.99,
  currency: 'EUR'
}, successCallback, errorCallback);

// Registrierung
TikTokEvents.trackRegistration('email'); // oder 'apple', 'google'

// Content ansehen
TikTokEvents.trackViewContent('video-456', 'video', {
  description: 'Tutorial Video'
});

// Manueller Kauf (nur für Non-StoreKit!)
TikTokEvents.trackPurchase(49.99, 'EUR', {
  content_id: 'web-premium',
  content_type: 'subscription'
});

// Abo
TikTokEvents.trackSubscription(9.99, 'EUR', 'monthly-premium');
```

### Standard Events

| Event | Beschreibung |
|-------|-------------|
| `LaunchAPP` | App gestartet (automatisch) |
| `InstallApp` | App installiert (automatisch) |
| `Registration` | Registrierung abgeschlossen |
| `Login` | User eingeloggt |
| `Search` | Suche durchgeführt |
| `ViewContent` | Content angesehen |
| `AddPaymentInfo` | Zahlungsinfo hinzugefügt |
| `Subscribe` | Abo abgeschlossen |
| `StartTrial` | Trial gestartet |
| `Purchase` | Kauf abgeschlossen (automatisch für StoreKit) |

---

## User Identifizierung (Advanced Matching)

Verbessert die Attribution durch Matching von User-Daten:

```javascript
// User identifizieren (Daten werden vom SDK gehasht)
TikTokEvents.identifyUser({
  email: 'user@example.com',
  phone: '+491234567890',
  externalId: 'user-id-123'
});

// Bei Logout
TikTokEvents.clearUser();
```

---

## TikTok Ads Manager Konfiguration

### Events testen (Debug Mode)

1. Setze `debug: true` bei `initialize()`
2. Mache Test-Aktionen in der App
3. Geh zu **TikTok Ads Manager → Tools → Events → Deine App → Ereignis testen**
4. Events sollten innerhalb von Sekunden erscheinen

### Production Events prüfen

1. Setze `debug: false` bei `initialize()`
2. Geh zu **TikTok Ads Manager → Tools → Events → Deine App → Überblick**
3. Events erscheinen nach 5-30 Minuten (manchmal bis zu 24h)

### SKAdNetwork konfigurieren

Für optimale iOS 14+ Attribution:

1. Geh zu **TikTok Ads Manager → Tools → Events → Deine App**
2. Klick auf **SKAN konfigurieren**
3. Wähle **Anpassung**
4. Füge Event hinzu:
   - Conversion-Wert: `1`
   - Ereignis: `Kaufen` / `Purchase`
   - Mindestwert: `5` USD
   - Höchstwert: `30` USD
5. Speichern

---

## Debugging & Troubleshooting

### Debug-Logging aktivieren

```javascript
TikTokEvents.initialize({ debug: true }, ...);

// Oder nachträglich
TikTokEvents.setDebug(true);
```

### SDK Status prüfen

```javascript
// Initialisiert?
TikTokEvents.isInitialized(function(ok) {
  console.log('Initialisiert:', ok);
});

// SDK Version
TikTokEvents.getVersion(function(version) {
  console.log('SDK Version:', version);
});
```

### Häufige Probleme

| Problem | Lösung |
|---------|--------|
| Events erscheinen nicht | Warte 5-30 Min, prüfe ob `debug: false` (dann nicht unter "Ereignis testen") |
| SDK init failed | Prüfe ob alle 3 IDs korrekt sind |
| ATT Dialog erscheint nicht | iOS zeigt ihn nur 1x pro App-Installation |
| Doppelte Purchase Events | Normal! SDK trackt automatisch – entferne manuelles `trackPurchase()` |

---

## App Tracking Transparency (ATT)

Das Plugin fügt automatisch den deutschen ATT-Text zur Info.plist hinzu:

> "Diese App nutzt Tracking, um dir relevantere Werbung zu zeigen und den Erfolg von Werbekampagnen zu messen."

### ATT-Text anpassen

In deiner `config.xml`:

```xml
<platform name="ios">
  <config-file target="*-Info.plist" parent="NSUserTrackingUsageDescription">
    <string>Dein eigener Tracking-Text hier</string>
  </config-file>
</platform>
```

---

## Vollständiges Beispiel

```javascript
// === App Start (index.js oder App.js) ===

document.addEventListener('deviceready', function() {
  
  // TikTok SDK initialisieren
  if (window.TikTokEvents) {
    TikTokEvents.initialize({ 
      debug: false  // true während Entwicklung
    }, function() {
      console.log('TikTok SDK ready');
    });
  }
  
}, false);


// === Nach Login/Registrierung ===

function onLoginSuccess() {
  // ATT Dialog zeigen
  if (window.TikTokEvents) {
    TikTokEvents.requestTrackingAuthorization(function(status) {
      console.log('ATT:', status);
    });
  }
}

function onRegisterSuccess(method) {
  // ATT Dialog zeigen
  if (window.TikTokEvents) {
    TikTokEvents.requestTrackingAuthorization(function(status) {
      console.log('ATT:', status);
    });
    
    // Registrierung tracken
    TikTokEvents.trackRegistration(method); // 'email', 'apple', 'google'
  }
}


// === Käufe ===
// Für StoreKit-Käufe: NICHTS TUN – SDK trackt automatisch!

// Nur für Non-StoreKit Käufe (z.B. Web):
function onWebPurchaseComplete(price, productId) {
  if (window.TikTokEvents) {
    TikTokEvents.trackPurchase(price, 'EUR', {
      content_id: productId,
      content_type: 'subscription'
    });
  }
}
```

---

## Checkliste vor App Store Release

- [ ] `debug: false` gesetzt
- [ ] Alle 3 TikTok IDs korrekt in Plugin-Variablen
- [ ] ATT-Dialog wird zu passendem Zeitpunkt gezeigt (nicht App-Start)
- [ ] SKAdNetwork in TikTok Ads Manager konfiguriert
- [ ] Test-Kauf im "Überblick" Tab erschienen (nicht "Ereignis testen")
- [ ] Manuelles `trackPurchase()` für StoreKit-Käufe entfernt (SDK macht es automatisch)

---

## Bekannte Einschränkungen

- Nur iOS (Android bei Bedarf erweiterbar)
- TikTok SDK Version ~1.3+ (via CocoaPods)
- SKAdNetwork Conversion Values sind auf 0-63 limitiert (Apple-Vorgabe)

---

## Lizenz

MIT

---

Made with ✨ by Aurora für ADS4U Digital
