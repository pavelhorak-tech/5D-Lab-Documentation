# VWAP Ultra - Webhook Format Reference

> **Dynamic VWAP Intelligence with Slope Analysis**
> Real-time VWAP levels, standard deviation bands, touch detection, and trend strength measurement

---

## 📊 Message Format

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

## 📋 Example Message

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

## 🔍 Field Breakdown

### Instrument & Timeframe
- **instrument:** Trading symbol (e.g., `NQ`, `ES`, `MNQ`, `MES`)
- **timeFrame:** Chart timeframe + chart type (e.g., `12RenkoTime`, `5MinuteTime`)

### Bar Information
- **barIndex:** Sequential bar number on chart
- **barTime:** Candle open time (start of the bar)
- **barLastTime:** Candle close time (end of the bar)

### VWAP Levels

| Field | Description |
|-------|-------------|
| `poc` | VWAP Point of Control (the VWAP line itself) |
| `dVAH1` | 1st Standard Deviation High |
| `dVAH2` | 2nd Standard Deviation High |
| `dVAH3` | 3rd Standard Deviation High |
| `dVAL1` | 1st Standard Deviation Low |
| `dVAL2` | 2nd Standard Deviation Low |
| `dVAL3` | 3rd Standard Deviation Low |

### Slope Analysis
- **pocSlopePerMinute:** Rate of change of VWAP POC line per minute
  - **Positive value** = VWAP rising = Uptrend
  - **Negative value** = VWAP falling = Downtrend
  - **Near zero** = Flat VWAP = Sideways/ranging market
  - Calculated over configurable lookback period (default: 15 bars)

### Touch Detection
- **touchedLevels:** Array of level names that price touched on this bar
  - Possible values: `"POC"`, `"dVAH1"`, `"dVAH2"`, `"dVAH3"`, `"dVAL1"`, `"dVAL2"`, `"dVAL3"`
  - Empty array `[]` if no levels touched
  - Multiple levels can be touched in single bar

---

## 🎯 Slope Interpretation

### Strong Uptrend
```
pocSlopePerMinute > 0.10
```
VWAP rising aggressively — strong bullish momentum

### Moderate Uptrend
```
0.03 < pocSlopePerMinute < 0.10
```
VWAP rising steadily — bullish bias

### Sideways / No Trend
```
-0.03 < pocSlopePerMinute < 0.03
```
VWAP flat — no directional bias, range-bound market

### Moderate Downtrend
```
-0.10 < pocSlopePerMinute < -0.03
```
VWAP falling steadily — bearish bias

### Strong Downtrend
```
pocSlopePerMinute < -0.10
```
VWAP falling aggressively — strong bearish momentum

**Note:** These thresholds are instrument-dependent. Adjust based on your instrument's typical volatility.

---

## 🔧 n8n Webhook Configuration

### Webhook URL Setup
1. Create a Webhook node in n8n (POST method)
2. Copy the webhook URL (e.g., `https://your-n8n.com/webhook/vwapultra`)
3. Configure in ATAS indicator settings:
   - Enable **Webhook** checkbox
   - Paste URL into **Webhook URL** field
   - Optionally set **Touch Tolerance (ticks)** for proximity alerts

### Parsing Example (n8n Code Node)

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

### Filter by Touched Levels

```javascript
// Only process if POC or dVAH1 was touched
const levels = $json.touchedLevels || [];
if (levels.includes('POC') || levels.includes('dVAH1')) {
  return $input.item;
} else {
  return null;
}
```

### Filter by Slope Strength

```javascript
// Only process strong trends (slope > 0.10 or < -0.10)
const slope = parseFloat($json.slope);
if (Math.abs(slope) > 0.10) {
  return $input.item;
} else {
  return null;
}
```

### Determine Trend Direction

```javascript
// Add trend classification
const slope = parseFloat($json.slope);
let trend = 'FLAT';

if (slope > 0.10) trend = 'STRONG UP';
else if (slope > 0.03) trend = 'UP';
else if (slope < -0.10) trend = 'STRONG DOWN';
else if (slope < -0.03) trend = 'DOWN';

return [{
  json: {
    ...$json,
    trend
  }
}];
```

---

## 📱 Telegram Alert Example

**Format for trading alerts:**

```
⚖️ VWAP Ultra Alert

NQ | 12Renko
Slope: 0.0875/min (UP)

Levels touched: dVAH1, POC

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

## 📱 Discord Alert Example

```
VWAP ULTRA
instrument: NQ
timeframe: 12Renko
bar time: 2026-03-06T15:30:45
--------------------------------------------
SLOPE: 0.0875/min → UPTREND
--------------------------------------------
POC:   21425.50
dVAH1: 21445.25  ← TOUCHED
dVAH2: 21465.00
dVAH3: 21485.25
dVAL1: 21405.75
dVAL2: 21386.00
dVAL3: 21366.25
--------------------------------------------
```

---

## ⚙️ Why VWAP Ultra?

### Standard ATAS VWAP limitations:
- No webhook capability
- No slope calculation
- No touch detection
- No automated alerts

### VWAP Ultra adds:
- **Complete level export** — All 7 levels (POC + 6 standard deviations) in every webhook
- **Slope analysis** — Instant trend strength measurement without looking at chart
- **Touch detection** — Know exactly which levels were hit
- **Automation-ready** — JSON format for n8n/Telegram/Google Sheets integration

**One webhook = complete VWAP context for the bar.**

---

## 🛠️ Troubleshooting

### No Webhook Messages Received
- Verify **Webhook** checkbox is enabled in ATAS indicator settings
- Confirm webhook URL is correct (test with webhook.site first)
- Check that VWAP is calculating (indicator visible on chart)
- Ensure chart has enough data for VWAP calculation

### Slope Always Shows 0
- Check that enough bars have loaded for slope calculation
- Slope requires minimum bars defined by **POC Slope Period** setting (default: 15)
- Slope resets when VWAP period resets (e.g., daily VWAP resets at midnight)

### touchedLevels Always Empty
- Increase **Touch Tolerance (ticks)** in indicator settings
- Price may not be reaching any VWAP levels
- Check that level values are valid (not 0)

### Too Many Webhooks
- Webhook fires once per bar
- Use larger timeframe for fewer webhooks
- Add filter node in n8n to only process specific conditions

---

## 📚 Related Documentation

- [semaPHorek Webhook Format](semaPHorek-Webhook-Format.md)
- [PatternAction Webhook Format](PatternAction-Webhook-Format.md)
- [Linescope Webhook Format](Linescope-Webhook-Format.md)
- [NODEtective Webhook Format](NODEtective-Webhook-Format.md)
- [Your First Webhook Receiver](../Getting-Started/02-Your-First-Webhook.md)
- [Testing Your Webhooks](../Getting-Started/03-Testing-Webhooks.md)

---

*Last Updated: March 6, 2026*
*Pavel Horák - ATAS Platform Expert & Official Partner*
