# semaPHorek - Webhook Format Referenz

> **Ampelsystem für Order Flow Intelligence**
> 9-Bedingungen Footprint-Analyse vereinfacht zu Go/Stop/Vorsicht-Signalen

---

## 📊 Nachrichtenformat

```
DD/MM/YYYY HH:MM:SS.fff INSTRUMENT TIMEFRAME LIGHTS STATUS CONDITIONS BARNUMBER OPEN HIGH LOW CLOSE VPOC
```

---

## 📋 Beispielnachricht

```
25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75
```

---

## 🔍 Feld-Aufschlüsselung

### Datum & Uhrzeit
- **Datum:** `DD/MM/YYYY` Format (z.B. `25/09/2025`)
- **Uhrzeit:** `HH:MM:SS.fff` mit Millisekunden (z.B. `18:27:08.861`)
- **Zeitzone:** Immer Prager Zeit (CET/CEST)

### Instrument & Zeitrahmen
- **Instrument:** Handelssymbol (z.B. `MNQ`, `ES`, `NQ`)
- **Zeitrahmen:** Chart-Zeitrahmen (z.B. `4Renko`, `5m`, `1h`)

### Signalinformationen
- **Lights:** Anzahl erfüllter Bedingungen (`0-9`)
  - 9 = Alle Bedingungen erfüllt (stärkstes Signal)
  - 0 = Keine Bedingungen erfüllt
- **Status:** Bar-Status
  - `C` = Candle geschlossen (abgeschlossene Bar)
  - `O` = Bar offen/in Bildung (Echtzeit-Update)

### Binäre Bedingungen (9 Ziffern: `0` oder `1`)
Positionsbasierte Darstellung von 9 Bedingungen:

| Position | Bedingung | Beschreibung |
|----------|-----------|--------------|
| 1 | Absorption Size | Große Absorption erkannt |
| 2 | Absorption Amount | Mehrere Absorptions-Cluster |
| 3 | PowerBar Volume | Institutionelles Volumen-Muster |
| 4 | Absolute Volume | Volumenschwellenwert überschritten |
| 5 | Delta | Delta-Divergenz erkannt |
| 6 | Finished Business | Null Kontrakte am Extrem |
| 7 | Diagonal Imbalances | Ungleichgewichts-Zonen vorhanden |
| 8 | Smart Money Tape | Tape-Reading-Muster |
| 9 | vPOC Positioning | Volume Point of Control Positionierung |

**Beispiel:** `111111101`
- Positionen 1-7: ✅ Erfüllt (alle Bedingungen erfüllt)
- Position 8: ✅ Erfüllt
- Position 9: ❌ Nicht erfüllt (vPOC-Positionierung qualifiziert nicht)

**Ergebnis:** 8/9 Bedingungen = 8 Lights

### Bar-Daten
- **Bar Number:** Fortlaufende Bar-Nummer (z.B. `37748`)
- **OHLC:** Open, High, Low, Close Preise
  - Open: `24576.75`
  - High: `24577.50`
  - Low: `24576.25`
  - Close: `24577.50`
- **vPOC:** Volume Point of Control Preisniveau (`24576.75`)

---

## 🎯 Signalqualität Interpretation

### Grünes Licht (7-9 Lights)
**Starker institutioneller Footprint erkannt**
- Multiple Konfluenz-Bedingungen
- Hochwahrscheinlichkeits-Setup
- Einstiegsvorbereitung erwägen

### Gelbes Licht (4-6 Lights)
**Moderate Signalstärke**
- Einige Bedingungen erfüllt
- Kontextabhängige Bewertung
- Auf zusätzliche Bestätigung warten

### Rotes Licht (0-3 Lights)
**Schwaches oder kein Signal**
- Wenige Bedingungen erfüllt
- Niedrig-Wahrscheinlichkeits-Umfeld
- Flat bleiben oder Risiko reduzieren

---

## 🔧 n8n Webhook Konfiguration

### Webhook URL Setup
1. Webhook-Node in n8n erstellen
2. Webhook URL kopieren (z.B. `https://your-n8n.com/webhook/semaphorek`)
3. In ATAS Indikator-Einstellungen konfigurieren:
   - Webhook aktivieren
   - URL einfügen
   - Trigger wählen: Bar Close (`C`) oder Echtzeit (`O`)

### Parsing-Beispiel (n8n Code Node)

```javascript
// Parse semaPHorek webhook message
const message = $input.item.json.body.toString();
const fields = message.split(' ');

return {
  json: {
    date: fields[0],
    time: fields[1],
    instrument: fields[2],
    timeframe: fields[3],
    lights: parseInt(fields[4]),
    status: fields[5],
    conditions: fields[6],
    barNumber: parseInt(fields[7]),
    open: parseFloat(fields[8]),
    high: parseFloat(fields[9]),
    low: parseFloat(fields[10]),
    close: parseFloat(fields[11]),
    vpoc: parseFloat(fields[12])
  }
};
```

### Nach Signalstärke filtern

```javascript
// Only process strong signals (7+ lights)
if ($json.lights >= 7) {
  return $input.item;
} else {
  return null; // Ignore weak signals
}
```

---

## 📱 Telegram Alert Beispiel

**Format für Trading Alerts:**

```
🚦 semaPHorek Signal

🟢 9 Lights | MNQ 4Renko
📊 OHLC: 24576.75 / 24577.50 / 24576.25 / 24577.50
📍 vPOC: 24576.75
🕐 18:27:08 CET

Conditions: 111111101
✅ Absorption Size
✅ Absorption Amount
✅ PowerBar Volume
✅ Absolute Volume
✅ Delta
✅ Finished Business
✅ Diagonal Imbalances
✅ Smart Money Tape
❌ vPOC Positioning
```

---

## ⚙️ Erweitert: Bedingungen-Parsing

Um einzelne Bedingungsstatus zu extrahieren:

```javascript
// Split binary string into array
const conditions = $json.conditions.split('');

const conditionNames = [
  'Absorption Size',
  'Absorption Amount',
  'PowerBar Volume',
  'Absolute Volume',
  'Delta',
  'Finished Business',
  'Diagonal Imbalances',
  'Smart Money Tape',
  'vPOC Positioning'
];

// Build condition summary
const summary = conditionNames.map((name, index) => ({
  condition: name,
  met: conditions[index] === '1'
}));

return { json: { conditions: summary } };
```

---

## 🛠️ Fehlerbehebung

### Keine Webhook-Nachrichten empfangen
- Webhook URL in ATAS-Einstellungen überprüfen
- Prüfen, ob Indikator im Chart aktiviert ist
- Bestätigen, dass "Webhook aktivieren" Checkbox AN ist
- Zuerst mit webhook.site testen (siehe [Testing Guide](../Erste-Schritte/03-Webhooks-testen.md))

### Nachrichten unvollständig oder unleserlich
- Überprüfen, dass n8n Webhook-Node `text/plain` Content-Type erwartet
- Prüfen, ob Firewall ATAS ausgehende Verbindungen nicht blockiert
- Bestätigen, dass keine Sonderzeichen in Webhook URL vorhanden sind

### Zu viele Nachrichten
- Trigger von Echtzeit (`O`) auf nur Bar Close (`C`) ändern
- Filter-Node in n8n hinzufügen (nur 7+ Lights verarbeiten)
- Chart-Zeitrahmen erhöhen (weniger Bars = weniger Nachrichten)

---

## 📚 Verwandte Dokumentation

- [Ihr erster Webhook Receiver](../Erste-Schritte/02-Ihr-erster-Webhook.md)
- [Webhooks testen](../Erste-Schritte/03-Webhooks-testen.md)
- [Häufige Probleme FAQ](../Fehlerbehebung/Haeufige-Probleme-FAQ.md)

---

*Zuletzt aktualisiert: 15. Oktober 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
