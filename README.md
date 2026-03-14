# cordova-plugin-tiktok-events

Cordova Plugin für das TikTok Events SDK (iOS) – App Event Tracking & Attribution für TikTok Ads.

## Installation

```bash
cordova plugin add /pfad/zu/cordova-plugin-tiktok-events \
  --variable TIKTOK_ACCESS_TOKEN=dein_access_token \
  --variable TIKTOK_APP_ID=deine_app_id \
  --variable TIKTOK_TIKTOK_APP_ID=deine_tiktok_app_id

# oder von GitHub
cordova plugin add https://github.com/felizertwo/cordova-plugin-tiktok-events.git \
  --variable TIKTOK_ACCESS_TOKEN=dein_access_token \
  --variable TIKTOK_APP_ID=deine_app_id \
  --variable TIKTOK_TIKTOK_APP_ID=deine_tiktok_app_id
```

## Voraussetzungen

- Cordova iOS >= 6.0.0
- iOS >= 12.0
- TikTok for Business Account

## Setup

### 1. TikTok for Business

1. Geh zu [TikTok Ads Manager](https://ads.tiktok.com/)
2. Erstelle eine App unter **Assets → Events → App Events**
3. Hole dir die drei IDs:
   - **Access Token** – aus den Marketing API Settings
   - **App ID** – Events Manager App ID
   - **TikTok App ID** – TikTok App ID

### 2. App Tracking Transparency (iOS 14+)

Das Plugin fügt automatisch den `NSUserTrackingUsageDescription` Text zur Info.plist hinzu. 
Du kannst ihn in deiner `config.xml` überschreiben:

```xml
<platform name="ios">
    <config-file target="*-Info.plist" parent="NSUserTrackingUsageDescription">
        <string>Dein eigener Tracking-Text hier</string>
    </config-file>
</platform>
```

## Verwendung

### Initialisierung

```javascript
// Am besten im deviceready Event

document.addEventListener('deviceready', function() {
    
    // 1. Erst ATT-Berechtigung anfragen (iOS 14+)
    TikTokEvents.requestTrackingAuthorization(function(status) {
        console.log('ATT Status:', status); // authorized, denied, restricted, notDetermined
        
        // 2. Dann SDK initialisieren (IDs kommen aus den Plugin-Variablen)
        TikTokEvents.initialize({
            debug: true  // Für Entwicklung
        }, function() {
            console.log('TikTok Events SDK initialisiert!');
        }, function(error) {
            console.error('Fehler:', error);
        });
    });
    
}, false);
```

> **Hinweis:** Die IDs werden automatisch aus den Plugin-Variablen gelesen.  
> Du kannst sie auch manuell übergeben: `{ accessToken: 'xxx', appId: 'xxx', tiktokAppId: 'xxx' }`

### Events tracken

```javascript
// Standard Event
TikTokEvents.trackEvent('ViewContent', {
    content_id: 'produkt-123',
    content_type: 'product',
    value: 29.99,
    currency: 'EUR'
});

// Registrierung
TikTokEvents.trackRegistration('email');

// Kauf
TikTokEvents.trackPurchase(49.99, 'EUR', {
    content_id: 'abo-premium',
    content_type: 'subscription'
});

// Abo
TikTokEvents.trackSubscription(9.99, 'EUR', 'monthly-premium');

// Content ansehen
TikTokEvents.trackViewContent('video-456', 'video', {
    description: 'Tutorial Video'
});
```

### Standard Events

| Event | Beschreibung |
|-------|-------------|
| `LaunchAPP` | App gestartet |
| `InstallApp` | App installiert |
| `Registration` | Registrierung abgeschlossen |
| `Login` | User eingeloggt |
| `Search` | Suche durchgeführt |
| `AddPaymentInfo` | Zahlungsinfo hinzugefügt |
| `Subscribe` | Abo abgeschlossen |
| `StartTrial` | Trial gestartet |
| `CompleteTutorial` | Tutorial beendet |
| `AchieveLevel` | Level erreicht |
| `SpendCredits` | Credits ausgegeben |
| `UnlockAchievement` | Achievement freigeschaltet |
| `GenerateLead` | Lead generiert |
| `Rate` | Bewertung abgegeben |

### User Identifizierung (Advanced Matching)

```javascript
// User identifizieren (Daten werden vom SDK gehasht)
TikTokEvents.identifyUser({
    email: 'user@example.com',
    phone: '+491234567890',
    externalId: 'user-id-123',
    externalUserName: 'username'
});

// Bei Logout
TikTokEvents.clearUser();
```

### Utility

```javascript
// SDK initialisiert?
TikTokEvents.isInitialized(function(initialized) {
    console.log('Initialisiert:', initialized);
});

// SDK Version
TikTokEvents.getVersion(function(version) {
    console.log('SDK Version:', version);
});

// Debug an/aus
TikTokEvents.setDebug(true);
```

## SwipeCheck Integration

Beispiel für typische SwipeCheck Events:

```javascript
// App Start (IDs kommen aus Plugin-Variablen)
TikTokEvents.initialize({ debug: false }, function() {
    console.log('TikTok ready');
});

// User registriert sich
TikTokEvents.trackRegistration('apple'); // oder 'email', 'google'

// User swiped ein Produkt
TikTokEvents.trackEvent('ViewContent', {
    content_id: productId,
    content_type: 'product',
    description: productName
});

// User kauft Premium
TikTokEvents.trackPurchase(4.99, 'EUR', {
    content_id: 'swipecheck-premium',
    content_type: 'subscription'
});
```

## Debugging

1. `debug: true` bei `initialize()` setzen
2. In Xcode Console nach `[TikTokEvents]` und `[TikTok]` filtern
3. Im TikTok Ads Manager unter **Events → Test Events** prüfen

## Bekannte Einschränkungen

- Nur iOS (Android kommt bei Bedarf)
- TikTok SDK Version ~1.3 (via CocoaPods)
- ATT-Dialog wird vom SDK automatisch unterstützt

## Lizenz

MIT

---

Made with ✨ by Aurora für ADS4U Digital
