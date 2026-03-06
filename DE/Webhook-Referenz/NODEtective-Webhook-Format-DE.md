# NODEtective (Ultra) - Webhook Format Referenz

> **Volume Profile Node Detection Intelligence**
> Automatisierte HVN/LVN Linien- und Zonen-Erkennung mit Proximity- und Touch-Alerts

---

## 📊 Nachrichtenformat

```json
{
  "DateTime": "string (ISO 8601)",
  "Instrument": "string",
  "Timeframe": "string",
  "LineOrZone": "string",
  "Node": "string",
  "Price_Touched": decimal,
  "IsProximity": boolean,
  "DistanceTicks": number,
  "ProximitySettingTicks": number
}
```

**Hinweis:** Feldnamen verwenden PascalCase (Großbuchstabe am Anfang), anders als PatternAction, das camelCase verwendet.

---

## 📋 Beispielnachrichten

### Direkte Linien-Berührung
```json
{
  "DateTime": "2026-01-27T15:42:18.1234567Z",
  "Instrument": "NQ",
  "Timeframe": "12RenkoTime",
  "LineOrZone": "Line",
  "Node": "HVN",
  "Price_Touched": 25741.25,
  "IsProximity": false,
  "DistanceTicks": 0,
  "ProximitySettingTicks": 0
}
```

### Zonen-Proximity-Alert
```json
{
  "DateTime": "2026-01-27T15:43:05.9876543Z",
  "Instrument": "NQ",
  "Timeframe": "12RenkoTime",
  "LineOrZone": "Zone",
  "Node": "LVN",
  "Price_Touched": 25728.50,
  "IsProximity": true,
  "DistanceTicks": 3,
  "ProximitySettingTicks": 5
}
```

---

## 🔍 Feld-Aufschlüsselung

### Zeitstempel
- **DateTime:** UTC-Zeitstempel im ISO 8601 Format (`DateTime.UtcNow`)
  - Immer UTC, nicht lokale Zeit
  - Beispiel: `2026-01-27T15:42:18.1234567Z`

### Instrument & Zeitrahmen
- **Instrument:** Handelssymbol (z.B. `NQ`, `ES`, `MNQ`, `MES`)
- **Timeframe:** Chart-Zeitrahmen + Chart-Typ (z.B. `12RenkoTime`, `5MinTime`)

### Event-Typ

| Feld | Werte | Beschreibung |
|-------|--------|-------------|
| **LineOrZone** | `Line` / `Zone` | Ob der Alert durch eine Node-Linie oder Zonen-Grenze ausgelöst wurde |
| **Node** | `HVN` / `LVN` | High Volume Node oder Low Volume Node |

Das ergibt 4 mögliche Kombinationen:

| LineOrZone | Node | Bedeutung |
|------------|------|---------|
| `Line` | `HVN` | Preis berührte/näherte sich der HVN-Linie (Volumen-Spitze) |
| `Line` | `LVN` | Preis berührte/näherte sich der LVN-Linie (Volumen-Tal) |
| `Zone` | `HVN` | Preis betrat/näherte sich der HVN-Zone (Hochvolumen-Bereich) |
| `Zone` | `LVN` | Preis betrat/näherte sich der LVN-Zone (Niedrigvolumen-Lücke) |

### Preisdaten
- **Price_Touched:** Der Node-Linien-Preis oder Zonen-Grenz-Preis, der berührt/angenähert wurde

### Proximity-Informationen
- **IsProximity:** `true` wenn Preis nah ist, aber noch nicht berührt hat; `false` bei direkter Berührung
- **DistanceTicks:** Wie viele Ticks vom Ziel entfernt (0 = direkte Berührung)
- **ProximitySettingTicks:** Der konfigurierte Proximity-Schwellenwert in ATAS Indikator-Einstellungen

---

## 🎯 Alert-Logik

### Touch vs. Proximity

**Touch (DistanceTicks = 0):**
- High/Low-Bereich der Preis-Bar schneidet direkt die Linie oder Zone
- `IsProximity` = `false`

**Proximity (DistanceTicks > 0):**
- Preis ist innerhalb der konfigurierten `ProximityTicks`-Distanz, hat aber noch nicht berührt
- `IsProximity` = `true`
- Feuert nur wenn `Proximity (Ticks)` Einstellung > 0 in ATAS

### Deduplizierung
- Jede Linie/Zone feuert nur **einmal** pro Neuberechnungs-Zyklus
- Alert-Schlüssel werden intern getrackt (z.B. `L:HVN:25741.25` oder `Z:LVN:25700.00:25710.00`)
- Minimum 300ms Intervall zwischen Alerts

---

## 🔧 n8n Webhook Konfiguration

### Webhook URL Setup
1. Webhook-Node in n8n erstellen (POST-Methode)
2. Webhook URL kopieren (z.B. `https://your-n8n.com/webhook/nodetective`)
3. In ATAS Indikator-Einstellungen konfigurieren:
   - **Enable Alerts** auf ON setzen
   - URL in **Webhook URL** Feld einfügen
   - Optional **Proximity (Ticks)** für Frühwarnungs-Alerts setzen

### Parsing-Beispiel (n8n Code Node)

```javascript
// Parse NODEtective webhook JSON body
const body = $input.all()[0].json.body;

const datetime = body.DateTime || '';
const instrument = body.Instrument || '';
const timeframe = body.Timeframe || '';
const lineOrZone = body.LineOrZone || '';
const node = body.Node || '';
const priceTouched = body.Price_Touched != null
  ? parseFloat(body.Price_Touched).toFixed(2) : '';
const isProximity = body.IsProximity || false;
const distanceTicks = body.DistanceTicks ?? 0;
const proxSetting = body.ProximitySettingTicks ?? 0;

return [{
  json: {
    datetime, instrument, timeframe, lineOrZone, node,
    priceTouched, isProximity, distanceTicks, proxSetting
  }
}];
```

### Nach Node-Typ filtern

```javascript
// Nur HVN-Berührungen verarbeiten (LVN ignorieren)
if ($json.node === 'HVN') {
  return $input.item;
} else {
  return null;
}
```

### Filter: Nur direkte Berührungen

```javascript
// Proximity-Alerts ignorieren, nur tatsächliche Berührungen verarbeiten
if (!$json.isProximity) {
  return $input.item;
} else {
  return null;
}
```

---

## 📱 Discord Alert Beispiel

**Formatierte Code-Block Nachricht:**

```
NODETECTIVE
Event: Line HVN TOUCH
Zeitpunkt: 2026-01-27T15:42:18Z
Instrument: NQ
Zeitrahmen: 12Renko
Preis: 25741.25
Distanz: 0 Ticks
--------------------------------------------
```

**Proximity-Alert:**

```
NODETECTIVE
Event: Zone LVN PROXIMITY
Zeitpunkt: 2026-01-27T15:43:05Z
Instrument: NQ
Zeitrahmen: 12Renko
Preis: 25728.50
Distanz: 3 Ticks (Einstellung: 5)
--------------------------------------------
```

---

## ⚙️ Erweitert: HVN vs LVN verstehen

### HVN (High Volume Node)
- **Was:** Preisniveau, wo signifikantes Volumen akkumuliert wurde
- **Trading-Bedeutung:** Wirkt als Magnet/Support/Resistance — Preis tendiert dazu, sich HVN zu nähern und dort zu konsolidieren
- **Alert-Verwendung:** Erwarten Sie, dass Preis verlangsamt, konsolidiert oder umkehrt

### LVN (Low Volume Node)
- **Was:** Preisniveau mit minimalem Volumen (Lücke im Profil)
- **Trading-Bedeutung:** Preis bewegt sich schnell durch LVN — wirkt als Übergangszone
- **Alert-Verwendung:** Erwarten Sie schnelle Preisbewegung durch dieses Level

### Zonen
- Zonen erweitern sich um jeden Node mit Standardabweichung (`kZ` Parameter)
- HVN-Zonen = Bereiche hoher Volumen-Konzentration
- LVN-Zonen = Bereiche niedrigen Volumens (Preis-Ablehnungs-Zonen)

---

## 🛠️ Fehlerbehebung

### Keine Webhook-Nachrichten empfangen
- Überprüfen, dass **Enable Alerts** in ATAS Indikator-Einstellungen ON ist
- Webhook URL ist im **Webhook URL** Feld eingetragen bestätigen
- Prüfen, dass der Indikator auf einem Chart mit Volume Profile Daten geladen ist
- Zuerst mit webhook.site testen

### Zu viele Alerts
- **Proximity (Ticks)** auf 0 setzen (nur direkte Berührungen feuern)
- Filter-Node in n8n verwenden, um nur `HVN` oder `LVN` zu verarbeiten (nicht beide)
- Größeren Sensitivity-Wert verwenden (weniger erkannte Nodes = weniger Alerts)

### Alerts feuern nur einmal
- Das ist beabsichtigt — jeder Node/Zone feuert einmal pro Neuberechnung
- Wenn das Profil neu berechnet wird (neue Bar), werden Alert-Schlüssel zurückgesetzt
- Dies verhindert Spam vom selben Level, das wiederholt berührt wird

### DateTime ist UTC, nicht lokale Zeit
- NODEtective sendet `DateTime.UtcNow` im ISO 8601 Format
- Bei Bedarf in n8n zu lokaler Zeit konvertieren:
  ```javascript
  const local = new Date(body.DateTime).toLocaleString('de-DE', {timeZone: 'Europe/Berlin'});
  ```

---

## 📚 Verwandte Dokumentation

- [PatternAction Webhook Format](../Webhook-Referenz/PatternAction-Webhook-Format.md)
- [semaPHorek Webhook Format](../Webhook-Referenz/semaPHorek-Webhook-Format.md)
- [Ihr erster Webhook Receiver](../Erste-Schritte/02-Ihr-erster-Webhook.md)
- [Webhooks testen](../Erste-Schritte/03-Webhooks-testen.md)

---

*Zuletzt aktualisiert: 27. Januar 2026*
*Pavel Horák - ATAS Platform Expert & Official Partner*
