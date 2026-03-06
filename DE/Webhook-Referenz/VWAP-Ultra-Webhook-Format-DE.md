# VWAP Ultra - Webhook Format Referenz

> **Dynamische VWAP Intelligence mit Slope-Analyse**
> Echtzeit VWAP-Levels, Standardabweichungs-Bänder, Touch-Erkennung und Trendstärke-Messung

---

## 📊 Nachrichtenformat

```json
{
  "instrument": "string",
  "timeFrame": "string",
  "barIndex": number,
  "barTime": "datetime",
  "barLastTime": "datetime",
  "poc": decimal,
  "dVAH3": decimal,
  "dVAH2": decimal,
  "dVAH1": decimal,
  "dVAL1": decimal,
  "dVAL2": decimal,
  "dVAL3": decimal,
  "pocSlopePerMinute": decimal,
  "touchedLevels": ["string"]
}
```

---

## 📋 Beispielnachricht

```json
{
  "instrument": "NQ",
  "timeFrame": "12RenkoTime",
  "barIndex": 8542,
  "barTime": "2026-03-06T15:30:00",
  "barLastTime": "2026-03-06T15:30:45",
  "poc": 21425.50,
  "dVAH3": 21485.25,
  "dVAH2": 21465.00,
  "dVAH1": 21445.25,
  "dVAL1": 21405.75,
  "dVAL2": 21386.00,
  "dVAL3": 21366.25,
  "pocSlopePerMinute": 0.0875,
  "touchedLevels": ["dVAH1", "POC"]
}
```

---

## 🔍 Feld-Aufschlüsselung

### Instrument & Zeitrahmen
- **instrument:** Handelssymbol (z.B. `NQ`, `ES`, `MNQ`, `MES`)
- **timeFrame:** Chart-Zeitrahmen + Chart-Typ (z.B. `12RenkoTime`, `5MinuteTime`)

### Bar-Informationen
- **barIndex:** Fortlaufende Bar-Nummer im Chart
- **barTime:** Kerzen-Eröffnungszeit (Start der Bar)
- **barLastTime:** Kerzen-Schlusszeit (Ende der Bar)

### VWAP Levels

| Feld | Beschreibung |
|-------|-------------|
| `poc` | VWAP Point of Control (die VWAP-Linie selbst) |
| `dVAH1` | 1. Standardabweichung Hoch |
| `dVAH2` | 2. Standardabweichung Hoch |
| `dVAH3` | 3. Standardabweichung Hoch |
| `dVAL1` | 1. Standardabweichung Tief |
| `dVAL2` | 2. Standardabweichung Tief |
| `dVAL3` | 3. Standardabweichung Tief |

### Slope-Analyse
- **pocSlopePerMinute:** Änderungsrate der VWAP POC-Linie pro Minute
  - **Positiver Wert** = VWAP steigt = Aufwärtstrend
  - **Negativer Wert** = VWAP fällt = Abwärtstrend
  - **Nahe Null** = Flache VWAP = Seitwärts/Range-Markt
  - Berechnet über konfigurierbare Lookback-Periode (Standard: 15 Bars)

### Touch-Erkennung
- **touchedLevels:** Array von Level-Namen, die der Preis auf dieser Bar berührt hat
  - Mögliche Werte: `"POC"`, `"dVAH1"`, `"dVAH2"`, `"dVAH3"`, `"dVAL1"`, `"dVAL2"`, `"dVAL3"`
  - Leeres Array `[]` wenn keine Levels berührt
  - Mehrere Levels können in einer einzelnen Bar berührt werden

---

## 🎯 Slope Interpretation

### Starker Aufwärtstrend
```
pocSlopePerMinute > 0.10
```
VWAP steigt aggressiv — starkes bullisches Momentum

### Moderater Aufwärtstrend
```
0.03 < pocSlopePerMinute < 0.10
```
VWAP steigt stetig — bullische Tendenz

### Seitwärts / Kein Trend
```
-0.03 < pocSlopePerMinute < 0.03
```
VWAP flach — keine Richtungstendenz, Range-gebundener Markt

### Moderater Abwärtstrend
```
-0.10 < pocSlopePerMinute < -0.03
```
VWAP fällt stetig — bearische Tendenz

### Starker Abwärtstrend
```
pocSlopePerMinute < -0.10
```
VWAP fällt aggressiv — starkes bearisches Momentum

**Hinweis:** Diese Schwellenwerte sind instrumentabhängig. Passen Sie sie basierend auf der typischen Volatilität Ihres Instruments an.

---

## 🔧 n8n Webhook Konfiguration

### Webhook URL Setup
1. Webhook-Node in n8n erstellen (POST-Methode)
2. Webhook URL kopieren (z.B. `https://your-n8n.com/webhook/vwapultra`)
3. In ATAS Indikator-Einstellungen konfigurieren:
   - **Webhook** Checkbox aktivieren
   - URL in **Webhook URL** Feld einfügen
   - Optional **Touch Tolerance (Ticks)** für Proximity-Alerts setzen

### Parsing-Beispiel (n8n Code Node)

```javascript
// Parse VWAP Ultra webhook JSON body
const body = $input.all()[0].json.body;

const instrument = body.instrument || '';
const timeFrame = body.timeFrame || '';
const barIndex = body.barIndex ?? 0;
const barTime = body.barTime || '';
const barLastTime = body.barLastTime || '';

const poc = body.poc != null ? parseFloat(body.poc).toFixed(2) : '';
const dVAH1 = body.dVAH1 != null ? parseFloat(body.dVAH1).toFixed(2) : '';
const dVAH2 = body.dVAH2 != null ? parseFloat(body.dVAH2).toFixed(2) : '';
const dVAH3 = body.dVAH3 != null ? parseFloat(body.dVAH3).toFixed(2) : '';
const dVAL1 = body.dVAL1 != null ? parseFloat(body.dVAL1).toFixed(2) : '';
const dVAL2 = body.dVAL2 != null ? parseFloat(body.dVAL2).toFixed(2) : '';
const dVAL3 = body.dVAL3 != null ? parseFloat(body.dVAL3).toFixed(2) : '';

const slope = body.pocSlopePerMinute != null 
  ? parseFloat(body.pocSlopePerMinute).toFixed(4) : '0';
const touchedLevels = body.touchedLevels || [];

return [{
  json: {
    instrument, timeFrame, barIndex, barTime, barLastTime,
    poc, dVAH1, dVAH2, dVAH3, dVAL1, dVAL2, dVAL3,
    slope, touchedLevels
  }
}];
```

### Nach berührten Levels filtern

```javascript
// Nur verarbeiten wenn POC oder dVAH1 berührt wurde
const levels = $json.touchedLevels || [];
if (levels.includes('POC') || levels.includes('dVAH1')) {
  return $input.item;
} else {
  return null;
}
```

### Nach Slope-Stärke filtern

```javascript
// Nur starke Trends verarbeiten (Slope > 0.10 oder < -0.10)
const slope = parseFloat($json.slope);
if (Math.abs(slope) > 0.10) {
  return $input.item;
} else {
  return null;
}
```

### Trendrichtung bestimmen

```javascript
// Trend-Klassifizierung hinzufügen
const slope = parseFloat($json.slope);
let trend = 'FLAT';

if (slope > 0.10) trend = 'STARK AUFWÄRTS';
else if (slope > 0.03) trend = 'AUFWÄRTS';
else if (slope < -0.10) trend = 'STARK ABWÄRTS';
else if (slope < -0.03) trend = 'ABWÄRTS';

return [{
  json: {
    ...$json,
    trend
  }
}];
```

---

## 📱 Telegram Alert Beispiel

**Format für Trading Alerts:**

```
⚖️ VWAP Ultra Alert

NQ | 12Renko
Slope: 0.0875/min (AUFWÄRTS)

Berührte Levels: dVAH1, POC

POC: 21425.50
━━━━━━━━━━━━━━
dVAH1: 21445.25
dVAH2: 21465.00
dVAH3: 21485.25
━━━━━━━━━━━━━━
dVAL1: 21405.75
dVAL2: 21386.00
dVAL3: 21366.25

Bar: 8542 | 15:30:45
```

---

## 📱 Discord Alert Beispiel

```
VWAP ULTRA
Instrument: NQ
Zeitrahmen: 12Renko
Bar Zeit: 2026-03-06T15:30:45
--------------------------------------------
SLOPE: 0.0875/min → AUFWÄRTSTREND
--------------------------------------------
POC:   21425.50
dVAH1: 21445.25  ← BERÜHRT
dVAH2: 21465.00
dVAH3: 21485.25
dVAL1: 21405.75
dVAL2: 21386.00
dVAL3: 21366.25
--------------------------------------------
```

---

## ⚙️ Warum VWAP Ultra?

### Standard ATAS VWAP Einschränkungen:
- Keine Webhook-Fähigkeit
- Keine Slope-Berechnung
- Keine Touch-Erkennung
- Keine automatisierten Alerts

### VWAP Ultra fügt hinzu:
- **Kompletter Level-Export** — Alle 7 Levels (POC + 6 Standardabweichungen) in jedem Webhook
- **Slope-Analyse** — Sofortige Trendstärke-Messung ohne auf den Chart zu schauen
- **Touch-Erkennung** — Wissen Sie genau, welche Levels getroffen wurden
- **Automatisierungs-bereit** — JSON-Format für n8n/Telegram/Google Sheets Integration

**Ein Webhook = vollständiger VWAP-Kontext für die Bar.**

---

## 🛠️ Fehlerbehebung

### Keine Webhook-Nachrichten empfangen
- Überprüfen, dass **Webhook** Checkbox in ATAS Indikator-Einstellungen aktiviert ist
- Webhook URL ist korrekt bestätigen (zuerst mit webhook.site testen)
- Prüfen, dass VWAP berechnet wird (Indikator im Chart sichtbar)
- Sicherstellen, dass Chart genügend Daten für VWAP-Berechnung hat

### Slope zeigt immer 0
- Prüfen, dass genügend Bars für Slope-Berechnung geladen sind
- Slope benötigt Minimum-Bars definiert durch **POC Slope Period** Einstellung (Standard: 15)
- Slope setzt zurück wenn VWAP-Periode zurücksetzt (z.B. Daily VWAP setzt um Mitternacht zurück)

### touchedLevels immer leer
- **Touch Tolerance (Ticks)** in Indikator-Einstellungen erhöhen
- Preis erreicht möglicherweise keine VWAP Levels
- Prüfen, dass Level-Werte gültig sind (nicht 0)

### Zu viele Webhooks
- Webhook feuert einmal pro Bar
- Größeren Zeitrahmen für weniger Webhooks verwenden
- Filter-Node in n8n hinzufügen um nur bestimmte Bedingungen zu verarbeiten

---

## 📚 Verwandte Dokumentation

- [semaPHorek Webhook Format](semaPHorek-Webhook-Format.md)
- [PatternAction Webhook Format](PatternAction-Webhook-Format.md)
- [Linescope Webhook Format](Linescope-Webhook-Format.md)
- [NODEtective Webhook Format](NODEtective-Webhook-Format.md)
- [Ihr erster Webhook Receiver](../Erste-Schritte/02-Ihr-erster-Webhook.md)
- [Webhooks testen](../Erste-Schritte/03-Webhooks-testen.md)

---

*Zuletzt aktualisiert: 6. März 2026*
*Pavel Horák - ATAS Platform Expert & Official Partner*
