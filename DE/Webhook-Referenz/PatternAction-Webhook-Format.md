# PatternAction - Webhook Format Referenz

> **Order Block und Breaker Block Erkennung**
> Reine Price Action Logik für institutionelle Level-Identifikation

---

## 📊 Nachrichtenformat

PatternAction sendet JSON-formatierte Webhook-Nachrichten via HTTP POST.

**Content-Type:** `application/json`

---

## 📋 Beispielnachricht

```json
{
  "eventCode": "NEWOBstrong",
  "instrument": "MNQ",
  "timeframe": "4Renko",
  "datetime": "2025-10-15 14:23:45",
  "side": "Support",
  "obBar": 37500,
  "chartBar": 37505,
  "obHigh": 21125.50,
  "obLow": 21120.25,
  "price": null
}
```

---

## 🔍 Feld-Aufschlüsselung

### Event-Informationen
- **eventCode:** Event-Typ-Identifikator (siehe Event-Typen Tabelle unten)
- **datetime:** Zeitstempel im Format `YYYY-MM-DD HH:MM:SS` (lokale Zeit)

### Instrument & Zeitrahmen
- **instrument:** Handelssymbol (z.B. `MNQ`, `ES`, `NQ`)
- **timeframe:** Chart-Zeitrahmen mit Typ (z.B. `4Renko`, `5m`, `1h`)

### Order Block Daten
- **side:** Order Block Richtung
  - `Support` - Bullischer Order Block (Nachfrage-Zone)
  - `Resistance` - Bearischer Order Block (Angebots-Zone)
- **obBar:** Bar-Nummer, wo Order Block gebildet wurde
- **chartBar:** Aktuelle Bar-Nummer beim Event
- **obHigh:** Obere Grenze der Order Block Zone
- **obLow:** Untere Grenze der Order Block Zone

### Preisinformationen
- **price:** Aktueller Preis zum Event-Zeitpunkt
  - Vorhanden bei Touch-Events (`OBstrongTOUCH`, `OBweakTOUCH`, etc.)
  - `null` bei Formations-Events (`NEWOBstrong`, `NEWOBweak`)

---

## 📋 Event-Typen

| Event Code | Beschreibung | Wann es auslöst |
|------------|-------------|-----------------|
| `NEWOBstrong` | Neuer starker Order Block bestätigt | Starkes institutionelles Level identifiziert |
| `NEWOBweak` | Neuer schwacher Order Block bestätigt | Schwaches institutionelles Level identifiziert |
| `OBweakTOstrong` | Order Block aufgewertet | Schwacher OB getestet und gehalten, zu Stark aufgewertet |
| `OBweakTOUCH` | Schwacher Order Block berührt | Preis erreichte schwache OB Zone |
| `OBstrongTOUCH` | Starker Order Block berührt | Preis erreichte starke OB Zone |
| `BBTOUCH` | Breaker Block berührt | Preis erreichte gebrochenen OB (jetzt Widerstand/Unterstützung) |
| `OBvPOCTOUCH` | Order Block vPOC berührt | Preis berührte Volume Point of Control innerhalb OB |
| `OBtoBB` | Order Block zu Breaker Block konvertiert | OB gebrochen, Level geflippt (Support→Widerstand oder umgekehrt) |

---

## 💡 Verwendungsbeispiele

### Beispiel 1: Order Block Formation Alert

**Webhook empfangen:**
```json
{
  "eventCode": "NEWOBstrong",
  "instrument": "MNQ",
  "timeframe": "4Renko",
  "datetime": "2025-10-15 14:23:45",
  "side": "Support",
  "obBar": 37500,
  "chartBar": 37505,
  "obHigh": 21125.50,
  "obLow": 21120.25,
  "price": null
}
```

**Dekodierte Information:**
- Starker Support Order Block bei MNQ bestätigt
- Zone: 21120.25 - 21125.50
- Vor 5 Bars gebildet (chartBar 37505 - obBar 37500)
- Potenzielle Long Entry Area wenn Preis zurückkehrt

**n8n Workflow Aktion:**
- In Google Sheets protokollieren: Instrument, Side, Level, Zeitstempel
- Telegram Alert senden: "Starker Support OB bestätigt MNQ 21120-21125"
- Im Chart-Datenbank für zukünftige Referenz markieren

---

### Beispiel 2: Order Block Touch Erkennung

**Webhook empfangen:**
```json
{
  "eventCode": "OBstrongTOUCH",
  "instrument": "ES",
  "timeframe": "5m",
  "datetime": "2025-10-15 15:30:12",
  "side": "Resistance",
  "obBar": 12340,
  "chartBar": 12380,
  "obHigh": 5432.75,
  "obLow": 5430.25,
  "price": 5431.50
}
```

**Dekodierte Information:**
- Starker Resistance Order Block berührt
- Aktueller Preis: 5431.50 (innerhalb Zone 5430.25-5432.75)
- Order Block vor 40 Bars gebildet
- Potenzielle Short Entry Signal

**n8n Workflow Aktion:**
- Prüfen, ob dieser OB zuvor in Datenbank protokolliert wurde
- Anzahl der Berührungen zählen (erste Berührung vs. mehrfache Berührungen)
- Distanz vom aktuellen Preis zu OB-Grenzen berechnen
- Prioritäts-Alert senden bei erster Berührung eines starken OB

---

### Beispiel 3: Breaker Block Konvertierung

**Webhook empfangen:**
```json
{
  "eventCode": "OBtoBB",
  "instrument": "NQ",
  "timeframe": "15m",
  "datetime": "2025-10-15 16:45:30",
  "side": "Support",
  "obBar": 8900,
  "chartBar": 8920,
  "obHigh": 21050.00,
  "obLow": 21045.00,
  "price": 21043.50
}
```

**Dekodierte Information:**
- Support Order Block gebrochen (Preis schloss unter obLow)
- Zone 21045-21050 wird jetzt zu Resistance (Breaker Block)
- Preis aktuell bei 21043.50 (unter gebrochener Zone)
- Marktstruktur verändert

**n8n Workflow Aktion:**
- Datenbank aktualisieren: OB als "Gebrochen" markieren
- Bias ändern: Vorheriger Support → jetzt Resistance
- Alle Long Alerts für diese Zone abbrechen
- Neuen Short Alert erstellen wenn Preis zur Zone zurückkehrt

---

### Beispiel 4: Multi-Timeframe Konfluenz

**Szenario:** PatternAction auf beiden 5m und 15m Charts, gleiches Instrument.

**Webhook 1 (5m Chart):**
```json
{
  "eventCode": "NEWOBstrong",
  "instrument": "MNQ",
  "timeframe": "5m",
  "side": "Support",
  "obHigh": 21125.50,
  "obLow": 21120.00
}
```

**Webhook 2 (15m Chart):**
```json
{
  "eventCode": "NEWOBstrong",
  "instrument": "MNQ",
  "timeframe": "15m",
  "side": "Support",
  "obHigh": 21126.00,
  "obLow": 21119.50
}
```

**Dekodierte Information:**
- Beide Zeitrahmen zeigen starken Support OB bei ~21120-21126
- Multi-Timeframe Ausrichtung (höhere Wahrscheinlichkeits-Zone)
- Überlappende Levels: 21120.00 - 21125.50

**n8n Workflow Aktion:**
- OB-Levels über Zeitrahmen vergleichen
- Überlappung erkennen (wenn obLow_tf1 <= obHigh_tf2 UND obHigh_tf1 >= obLow_tf2)
- Überlappungs-Zone berechnen: MAX(obLow_tf1, obLow_tf2) bis MIN(obHigh_tf1, obHigh_tf2)
- Konfluenz-Alert mit Überlappungs-Zone senden

---

### Beispiel 5: Order Block Performance Datenbank

**Datenbank-Schema (Google Sheets / Airtable):**

| Timestamp | Instrument | Timeframe | Side | Event | obLow | obHigh | Price | Status |
|-----------|------------|-----------|------|-------|-------|--------|-------|--------|
| 14:23:45 | MNQ | 4Renko | Support | NEWOBstrong | 21120.25 | 21125.50 | - | Aktiv |
| 15:30:12 | MNQ | 4Renko | Support | OBstrongTOUCH | 21120.25 | 21125.50 | 21121.00 | Getestet |
| 15:35:08 | MNQ | 4Renko | Support | OBstrongTOUCH | 21120.25 | 21125.50 | 21119.50 | Getestet |
| 16:10:22 | MNQ | 4Renko | Support | OBtoBB | 21120.25 | 21125.50 | 21118.00 | Gebrochen |

**Analysefähigkeiten:**
- Berührungen vor Bruch zählen (dieser OB: 2 Berührungen, dann gebrochen)
- Halte-Prozentsatz berechnen (starke vs. schwache OBs)
- Zeit zwischen Formation und erster Berührung tracken
- Distanz nach OB-Berührung messen (Win/Loss-Tracking)

---

## 🔧 n8n Webhook Konfiguration

### Webhook Node Setup
1. Webhook-Node in n8n erstellen
2. HTTP Method setzen: `POST`
3. Path setzen: `patternaction` (oder beschreibender Name)
4. Authentication: None (Sicherheit in Produktion bei Bedarf hinzufügen)
5. Response: Immediately

### Beispiel Produktions-URL
```
https://your-n8n.app/webhook/patternaction-mnq
```

### ATAS Indikator Konfiguration
1. PatternAction Indikator-Einstellungen öffnen
2. "Webhook" Sektion finden
3. Webhook aktivieren: ✅ ON
4. Webhook URL: n8n Webhook URL einfügen
5. OK klicken

---

## 📱 Beispiel Telegram Alert Format

**Einfacher Alert:**
```
📊 PatternAction Alert

Event: Starker Support OB Touch
Instrument: MNQ 4Renko
Level: 21120.25 - 21125.50
Preis: 21121.00
Zeit: 15:30:12
```

**Erweiterter Alert mit Kontext:**
```
📊 PatternAction | MNQ 4Renko

🟢 Starker Support OB Touch
Zone: 21120.25 - 21125.50
Aktuell: 21121.00

Kontext:
• Gebildet: Vor 40 Bars
• Berührungen: 1. Berührung
• Multi-TF: ✅ Abgestimmt mit 15m
```

---

## 🛠️ Fehlerbehebung

### Keine Webhooks empfangen
- Webhook URL in ATAS-Einstellungen überprüfen
- "Webhook aktivieren" Checkbox ist AN prüfen
- Bestätigen, dass Indikator im Chart aktiv ist
- Zuerst mit webhook.site testen

### Doppelte Nachrichten
- Prüfen, ob mehrere PatternAction Instanzen im selben Chart
- Webhook URL nur einmal konfiguriert überprüfen
- Jede Chart/Zeitrahmen Kombination sollte einzigartigen Webhook-Pfad haben

### Fehlendes Preisfeld
- `price` Feld ist `null` bei Formations-Events (NEWOBstrong, NEWOBweak)
- `price` Feld enthält nur bei Touch-Events einen Wert
- Dies ist erwartetes Verhalten, kein Fehler

---

## 📚 Verwandte Dokumentation

- [Erste Schritte mit Webhooks](../Erste-Schritte/02-Ihr-erster-Webhook.md)
- [Webhooks testen](../Erste-Schritte/03-Webhooks-testen.md)
- [Häufige Probleme FAQ](../Fehlerbehebung/Haeufige-Probleme-FAQ.md)

---

*Zuletzt aktualisiert: 15. Oktober 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
