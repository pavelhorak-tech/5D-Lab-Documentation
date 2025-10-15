# Linescope Ultra - Webhook Format Referenz

**Indikator:** Linescope Ultra
**Version:** 2.3 (22. September 2025)
**Format:** JSON

---

## Übersicht

Linescope Ultra sendet Webhooks, wenn signifikante Level-Events auftreten:
- Erste Berührungen von Schlüssel-Levels
- Retests gebrochener Levels
- Berührungen geflippter Levels
- Neue TPO Tails erscheinen (Buying/Selling Tails)

Jeder Webhook enthält vollständigen Kontext über das Event, Level-Details und formatierte Nachricht.

---

## Webhook Konfiguration

**Einstellungs-Ort:** Alerts Sektion → "Webhook URL"

**Aktivierungs-Schritte:**
1. "Enable" Checkbox für Webhook URL aktivieren
2. Ihre n8n Webhook URL eingeben
3. Alle konfigurierten Level-Events lösen automatisch Webhooks aus

---

## JSON Payload Struktur

```json
{
  "date": "2025-10-15",
  "time": "14:30:00",
  "instrument": "MNQ",
  "timeframe": "4 Renko",
  "type": "first touch",
  "price": 24575.50,
  "level": {
    "label": "PDH",
    "source": "OHLC",
    "period": "Day",
    "ltype": "High"
  },
  "message": "15.10.2025 14:30 | MNQ | 4 Renko | ⬆️ first touch | PDH | 24575.50"
}
```

---

## Feld-Aufschlüsselung

### Root-Felder

| Feld | Typ | Beschreibung | Beispiel |
|-------|------|-------------|---------|
| `date` | string | Datum im YYYY-MM-DD Format | `"2025-10-15"` |
| `time` | string | Zeit im HH:mm:ss Format | `"14:30:00"` |
| `instrument` | string | Handelsinstrument Symbol | `"MNQ"`, `"NQ"`, `"ES"` |
| `timeframe` | string | Chart-Zeitrahmen | `"4 Renko"`, `"5 min"` |
| `type` | string | Event-Typ (siehe unten) | `"first touch"` |
| `price` | number | Level-Preis wo Event auftrat | `24575.50` |
| `message` | string | Menschenlesbare formatierte Nachricht | Siehe Beispiele unten |

### Level Objekt

| Feld | Typ | Beschreibung | Beispiel |
|-------|------|-------------|---------|
| `label` | string | Level-Bezeichnung/Name | `"PDH"`, `"PWH"`, `"VPOC"` |
| `source` | string | Level-Quelltyp | `"OHLC"`, `"VWAP"`, `"VolumeProfile"`, `"TPOProfile"`, `"Sessions"` |
| `period` | string | Periodenspanne | `"Day"`, `"Week"`, `"Month"` |
| `ltype` | string | Level-Typ | `"High"`, `"Low"`, `"Open"`, `"Close"`, `"VAH"`, `"VAL"`, `"POC"`, `"BT"`, `"ST"` |

---

## Event-Typen

### 1. **first touch**
Level zum ersten Mal berührt nach Erscheinen.

**Beispiel:**
```json
{
  "type": "first touch",
  "price": 24580.00,
  "level": {
    "label": "PDH",
    "source": "OHLC",
    "period": "Day",
    "ltype": "High"
  },
  "message": "15.10.2025 14:30 | MNQ | 4 Renko | ⬆️ first touch | PDH | 24580.00"
}
```

### 2. **broken level touch**
Zuvor gebrochenes Level erneut berührt (Retest).

**Beispiel:**
```json
{
  "type": "broken level touch",
  "price": 24550.00,
  "level": {
    "label": "PDL",
    "source": "OHLC",
    "period": "Day",
    "ltype": "Low"
  },
  "message": "15.10.2025 15:00 | MNQ | 4 Renko | ⬇️ broken level touch | PDL | 24550.00"
}
```

### 3. **flipped level touch**
Level, das von Support zu Resistance geflippt wurde (oder umgekehrt), wird berührt.

**Beispiel:**
```json
{
  "type": "flipped level touch",
  "price": 24565.00,
  "level": {
    "label": "VPOC",
    "source": "VolumeProfile",
    "period": "Day",
    "ltype": "POC"
  },
  "message": "15.10.2025 15:30 | MNQ | 4 Renko | ↔️ flipped level touch | VPOC | 24565.00"
}
```

### 4. **buying tail appeared**
Neuer TPO Buying Tail erkannt (aktuelles Tages-Composite).

**Beispiel:**
```json
{
  "type": "buying tail appeared",
  "price": 24540.00,
  "level": {
    "label": "BT",
    "source": "TPOProfile",
    "period": "Day",
    "ltype": "BTcd"
  },
  "message": "15.10.2025 16:00 | MNQ | 4 Renko | ⬆️ buying tail appeared | BT | 24540.00"
}
```

### 5. **selling tail appeared**
Neuer TPO Selling Tail erkannt (aktuelles Tages-Composite).

**Beispiel:**
```json
{
  "type": "selling tail appeared",
  "price": 24590.00,
  "level": {
    "label": "ST",
    "source": "TPOProfile",
    "period": "Day",
    "ltype": "STcd"
  },
  "message": "15.10.2025 16:15 | MNQ | 4 Renko | ⬇️ selling tail appeared | ST | 24590.00"
}
```

---

## Level-Quellen

| Source | Beschreibung | Beispiel-Labels |
|--------|-------------|----------------|
| `OHLC` | Perioden High/Low/Open/Close | `PDH`, `PWL`, `PMO`, `PDC` |
| `VWAP` | Volume Weighted Average Price Levels | `VWAP`, `VWAP+1SD`, `VWAP-2SD` |
| `VolumeProfile` | Volume Profile Levels | `VPOC`, `VAH`, `VAL` |
| `TPOProfile` | Time Price Opportunity Levels | `TPOC`, `VAH`, `VAL`, `BT`, `ST` |
| `Sessions` | Session-Extreme (Asia/Europe/US) | `AsiaH`, `EuropeL`, `USH` |
| `InitialBalance` | Initial Balance Ranges | `IBH`, `IBL` |

---

## Level-Typen

| Typ | Beschreibung |
|------|-------------|
| `High` | Perioden-High |
| `Low` | Perioden-Low |
| `Open` | Perioden-Open |
| `Close` | Perioden-Close |
| `POC` | Point of Control (max. Volumen/TPO) |
| `VAH` | Value Area High |
| `VAL` | Value Area Low |
| `BT` | Buying Tail (TPO) |
| `ST` | Selling Tail (TPO) |
| `BTcd` | Buying Tail (Aktueller Tag) |
| `STcd` | Selling Tail (Aktueller Tag) |

---

## Touch-Richtungs-Pfeile

Das `message` Feld enthält visuelle Indikatoren:

| Pfeil | Bedeutung |
|-------|---------|
| ⬆️ | Candle schloss über Level (bullische Berührung) |
| ⬇️ | Candle schloss unter Level (bearische Berührung) |
| ↔️ | Candle schloss auf Level (neutral) |

---

## Verwendungsbeispiele

### Beispiel 1: Telegram Alert bei PDH Touch

**n8n Workflow:**
```
Webhook → IF Node (prüfe type="first touch" UND label="PDH") → Telegram
```

**Filter Expression:**
```javascript
{{ $json.type === "first touch" && $json.level.label === "PDH" }}
```

**Telegram Nachricht:**
```
🔔 {{ $json.level.label }} berührt bei {{ $json.price }}
{{ $json.instrument }} {{ $json.timeframe }}
{{ $json.message }}
```

### Beispiel 2: Alle Tail-Erscheinungen in Google Sheets protokollieren

**n8n Workflow:**
```
Webhook → IF Node (prüfe type enthält "tail appeared") → Google Sheets
```

**Filter Expression:**
```javascript
{{ $json.type.includes("tail appeared") }}
```

**Sheet-Spalten:**
- Datum: `{{ $json.date }}`
- Zeit: `{{ $json.time }}`
- Instrument: `{{ $json.instrument }}`
- Typ: `{{ $json.type }}`
- Preis: `{{ $json.price }}`
- Label: `{{ $json.level.label }}`

### Beispiel 3: Gebrochene Level-Retests tracken

**n8n Workflow:**
```
Webhook → IF Node (prüfe type="broken level touch") → Datenbank + Telegram
```

**Anwendungsfall:** Überwachen, wenn zuvor gebrochene Levels erneut getestet werden - oft signifikant für Trend-Fortsetzung/Umkehr.

---

## Häufige Level-Labels

### Tages-Levels
- `PDH` - Previous Day High
- `PDL` - Previous Day Low
- `PDO` - Previous Day Open
- `PDC` - Previous Day Close

### Wochen-Levels
- `PWH` - Previous Week High
- `PWL` - Previous Week Low
- `PWO` - Previous Week Open
- `PWC` - Previous Week Close

### Monats-Levels
- `PMH` - Previous Month High
- `PML` - Previous Month Low
- `PMO` - Previous Month Open
- `PMC` - Previous Month Close

### Profil-Levels
- `VPOC` - Volume Point of Control
- `TPOC` - Time Price Opportunity Point of Control
- `VAH` - Value Area High
- `VAL` - Value Area Low

### Session-Levels
- `AsiaH`, `AsiaL` - Asien Session Extreme
- `EuropeH`, `EuropeL` - Europa Session Extreme
- `USH`, `USL` - US Session Extreme

### Initial Balance
- `IBH`, `IBL` - Initial Balance High/Low (verschiedene Perioden)

---

## Fehlerbehebung

### Keine Webhooks empfangen

1. **Webhook URL ist aktiviert prüfen:**
   - Settings → Alerts → Webhook URL → Enable Checkbox ✓

2. **URL ist korrekt überprüfen:**
   - Zuerst mit webhook.site testen
   - Auf HTTPS prüfen (nicht HTTP)

3. **Level-Alerts sind aktiviert bestätigen:**
   - Jeder Level-Typ hat individuellen Alert-Toggle
   - Webhook feuert, wenn Level-Event auftritt

4. **n8n Webhook-Node prüfen:**
   - Muss "Webhook" Node sein (nicht HTTP Request)
   - Pfad sollte mit Indikator URL übereinstimmen
   - Method: POST
   - Response: Return 200 OK

### Doppelte Webhooks

Linescope hat eingebaute Deduplizierung pro Bar. Sie sollten keine doppelten Events für dieselbe Bar/Level/Event-Kombination erhalten.

### Fehlende Level-Daten

Wenn `level` Felder `null` sind:
- Event könnte von einem Level ohne vollständige Metadaten sein
- Prüfen, dass Level-Quelle im Indikator korrekt konfiguriert ist

---

## Deduplizierungs-Logik

Linescope verhindert doppelte Webhooks mit diesem Schlüssel:
```
{bar}|{type}|{price}|{levelLabel}
```

Sobald ein spezifisches Event auf einer Bar feuert, wird es nicht erneut feuern bis zur nächsten Bar, selbst wenn Preis das Level mehrfach innerhalb derselben Candle berührt.

---

## Performance-Hinweise

- Webhooks werden asynchron gesendet (nicht-blockierend)
- 5-Sekunden Timeout pro Webhook-Request
- Fehlgeschlagene Webhook-Sendungen stoppen nicht die Indikator-Ausführung
- Keine Retry-Logik - wenn Webhook fehlschlägt, geht Event verloren

---

## Integrations-Tipps

### 1. Multi-Timeframe Konfluenz
Tracken Sie dasselbe Level, das über mehrere Zeitrahmen berührt wird:
```javascript
// Store touches in context
const key = `${$json.level.label}_${$json.price}`;
$context.set(key, $json);
```

### 2. Level-Stärke-Bewertung
Zählen Sie, wie oft ein Level hält:
```javascript
// Increment counter on each touch that doesn't break
if ($json.type === "first touch") {
  // Level held - increment strength score
}
```

### 3. Automatisiertes Trade-Journal
Protokollieren Sie jede Level-Interaktion mit Marktkontext für spätere Analyse.

---

## Verwandte Dokumentation

- [n8n Konto erstellen](../Erste-Schritte/01-n8n-Konto-erstellen.md)
- [Ihr erster Webhook](../Erste-Schritte/02-Ihr-erster-Webhook.md)
- [Webhooks testen](../Erste-Schritte/03-Webhooks-testen.md)
- [semaPHorek Webhook Format](semaPHorek-Webhook-Format.md)
- [PatternAction Webhook Format](PatternAction-Webhook-Format.md)

---

**Fragen?** Fragen Sie im Discord #-chat oder #-diskussion

**Problem gefunden?** DM an Pavel Horák

---

*Dokumentationsversion: 1.0 | Zuletzt aktualisiert: 15. Oktober 2025*
