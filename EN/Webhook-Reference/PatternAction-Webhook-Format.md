# PatternAction - Webhook Format Reference

> **Order Block and Breaker Block Detection**
> Pure price action logic for institutional level identification

---

## 📊 Message Format

PatternAction sends JSON-formatted webhook messages via HTTP POST.

**Content-Type:** `application/json`

---

## 📋 Example Message

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

## 🔍 Field Breakdown

### Event Information
- **eventCode:** Event type identifier (see Event Types table below)
- **datetime:** Timestamp in format `YYYY-MM-DD HH:MM:SS` (local time)

### Instrument & Timeframe
- **instrument:** Trading symbol (e.g., `MNQ`, `ES`, `NQ`)
- **timeframe:** Chart timeframe with type (e.g., `4Renko`, `5m`, `1h`)

### Order Block Data
- **side:** Order Block direction
  - `Support` - Bullish Order Block (demand zone)
  - `Resistance` - Bearish Order Block (supply zone)
- **obBar:** Bar number where Order Block was formed
- **chartBar:** Current bar number when event occurred
- **obHigh:** Upper boundary of Order Block zone
- **obLow:** Lower boundary of Order Block zone

### Price Information
- **price:** Current price at event time
  - Present for touch events (`OBstrongTOUCH`, `OBweakTOUCH`, etc.)
  - `null` for formation events (`NEWOBstrong`, `NEWOBweak`)

---

## 📋 Event Types

| Event Code | Description | When It Fires |
|------------|-------------|---------------|
| `NEWOBstrong` | New Strong Order Block confirmed | Strong institutional level identified |
| `NEWOBweak` | New Weak Order Block confirmed | Weak institutional level identified |
| `OBweakTOstrong` | Order Block upgraded | Weak OB tested and held, upgraded to Strong |
| `OBweakTOUCH` | Weak Order Block touched | Price reached weak OB zone |
| `OBstrongTOUCH` | Strong Order Block touched | Price reached strong OB zone |
| `BBTOUCH` | Breaker Block touched | Price reached broken OB (now resistance/support) |
| `OBvPOCTOUCH` | Order Block vPOC touched | Price touched Volume Point of Control within OB |
| `OBtoBB` | Order Block converted to Breaker Block | OB broken, level flipped (support→resistance or vice versa) |

---

## 💡 Usage Examples

### Example 1: Order Block Formation Alert

**Webhook received:**
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

**Decoded information:**
- Strong Support Order Block confirmed at MNQ
- Zone: 21120.25 - 21125.50
- Formed 5 bars ago (chartBar 37505 - obBar 37500)
- Potential long entry area when price returns

**n8n workflow action:**
- Log to Google Sheets: Instrument, Side, Level, Timestamp
- Send Telegram alert: "Strong Support OB confirmed MNQ 21120-21125"
- Mark on chart database for future reference

---

### Example 2: Order Block Touch Detection

**Webhook received:**
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

**Decoded information:**
- Strong Resistance Order Block touched
- Current price: 5431.50 (within zone 5430.25-5432.75)
- Order Block formed 40 bars ago
- Potential short entry signal

**n8n workflow action:**
- Check if this OB was previously logged in database
- Count number of touches (first touch vs. multiple touches)
- Calculate distance from current price to OB boundaries
- Send priority alert if first touch of strong OB

---

### Example 3: Breaker Block Conversion

**Webhook received:**
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

**Decoded information:**
- Support Order Block broken (price closed below obLow)
- Zone 21045-21050 now becomes Resistance (Breaker Block)
- Price currently at 21043.50 (below broken zone)
- Market structure changed

**n8n workflow action:**
- Update database: Mark OB as "Broken"
- Change bias: Previous Support → now Resistance
- Cancel any long alerts for this zone
- Create new short alert if price returns to zone

---

### Example 4: Multi-Timeframe Confluence

**Scenario:** PatternAction on both 5m and 15m charts, same instrument.

**Webhook 1 (5m chart):**
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

**Webhook 2 (15m chart):**
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

**Decoded information:**
- Both timeframes show Strong Support OB at ~21120-21126
- Multi-timeframe alignment (higher probability zone)
- Overlapping levels: 21120.00 - 21125.50

**n8n workflow action:**
- Compare OB levels across timeframes
- Detect overlap (if obLow_tf1 <= obHigh_tf2 AND obHigh_tf1 >= obLow_tf2)
- Calculate overlap zone: MAX(obLow_tf1, obLow_tf2) to MIN(obHigh_tf1, obHigh_tf2)
- Send confluence alert with overlap zone

---

### Example 5: Order Block Performance Database

**Database schema (Google Sheets / Airtable):**

| Timestamp | Instrument | Timeframe | Side | Event | obLow | obHigh | Price | Status |
|-----------|------------|-----------|------|-------|-------|--------|-------|--------|
| 14:23:45 | MNQ | 4Renko | Support | NEWOBstrong | 21120.25 | 21125.50 | - | Active |
| 15:30:12 | MNQ | 4Renko | Support | OBstrongTOUCH | 21120.25 | 21125.50 | 21121.00 | Tested |
| 15:35:08 | MNQ | 4Renko | Support | OBstrongTOUCH | 21120.25 | 21125.50 | 21119.50 | Tested |
| 16:10:22 | MNQ | 4Renko | Support | OBtoBB | 21120.25 | 21125.50 | 21118.00 | Broken |

**Analysis capabilities:**
- Count touches before break (this OB: 2 touches, then broken)
- Calculate hold percentage (strong vs weak OBs)
- Track time between formation and first touch
- Measure distance traveled after OB touch (win/loss tracking)

---

## 🔧 n8n Webhook Configuration

### Webhook Node Setup
1. Create webhook node in n8n
2. Set HTTP Method: `POST`
3. Set Path: `patternaction` (or descriptive name)
4. Authentication: None (add security in production if needed)
5. Response: Immediately

### Example Production URL
```
https://your-n8n.app/webhook/patternaction-mnq
```

### ATAS Indicator Configuration
1. Open PatternAction indicator settings
2. Find "Webhook" section
3. Enable Webhook: ✅ ON
4. Webhook URL: Paste n8n webhook URL
5. Click OK

---

## 📱 Example Telegram Alert Format

**Simple alert:**
```
📊 PatternAction Alert

Event: Strong Support OB Touch
Instrument: MNQ 4Renko
Level: 21120.25 - 21125.50
Price: 21121.00
Time: 15:30:12
```

**Advanced alert with context:**
```
📊 PatternAction | MNQ 4Renko

🟢 Strong Support OB Touch
Zone: 21120.25 - 21125.50
Current: 21121.00

Context:
• Formed: 40 bars ago
• Touches: 1st touch
• Multi-TF: ✅ Aligned with 15m
```

---

## 🛠️ Troubleshooting

### No Webhooks Received
- Verify webhook URL is correct in ATAS settings
- Check "Enable Webhook" checkbox is ON
- Confirm indicator is active on chart
- Test with webhook.site first

### Duplicate Messages
- Check if multiple PatternAction instances on same chart
- Verify webhook URL configured only once
- Each chart/timeframe combination should have unique webhook path

### Missing Price Field
- `price` field is `null` for formation events (NEWOBstrong, NEWOBweak)
- `price` field contains value only for touch events
- This is expected behavior, not an error

---

## 📚 Related Documentation

- [Getting Started with Webhooks](../Getting-Started/02-Your-First-Webhook.md)
- [Testing Your Webhooks](../Getting-Started/03-Testing-Webhooks.md)
- [Common Issues FAQ](../Troubleshooting/Common-Issues-FAQ.md)

---

*Last Updated: October 15, 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
