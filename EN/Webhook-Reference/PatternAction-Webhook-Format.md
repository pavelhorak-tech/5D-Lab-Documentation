# PatternAction Master (Ultra) - Webhook Format Reference

> **Order Block & Market Structure Intelligence**
> Automated detection of Order Blocks, Breaker Blocks, CHoCH/BOS structure events, and lifecycle notifications with real-time webhooks

---

## 📊 Message Formats

PatternAction sends two types of webhook payloads:

### Order Block Events Payload

```json
{
  "eventCode": "string",
  "instrument": "string",
  "timeframe": "string",
  "datetime": "string",
  "barTime": "string",
  "side": "string",
  "obBar": number,
  "chartBar": number,
  "obHigh": decimal,
  "obLow": decimal,
  "price": decimal | null
}
```

### Structure Events Payload (CHoCH/BOS)

```json
{
  "eventCode": "string",
  "instrument": "string",
  "timeframe": "string",
  "datetime": "string",
  "barTime": "string",
  "structureType": "string",
  "direction": "string",
  "swingBar": number,
  "breakBar": number,
  "chartBar": number,
  "price": decimal,
  "breakPrice": decimal,
  "touchPrice": decimal | null
}
```

---

## 📋 Example Messages

### New Strong Order Block

```json
{
  "eventCode": "NEWOBstrong",
  "instrument": "NQ",
  "timeframe": "12RenkoTime",
  "datetime": "28.01.2026 15:58:26",
  "barTime": "28.01.2026 14:10:00",
  "side": "Support",
  "obBar": 8272,
  "chartBar": 8277,
  "obHigh": 25740.50,
  "obLow": 25737.25,
  "price": null
}
```

### Strong OB Touch

```json
{
  "eventCode": "OBstrongTOUCH",
  "instrument": "NQ",
  "timeframe": "12RenkoTime",
  "datetime": "28.01.2026 15:58:39",
  "barTime": "28.01.2026 14:10:45",
  "side": "Support",
  "obBar": 8272,
  "chartBar": 8278,
  "obHigh": 25740.50,
  "obLow": 25737.25,
  "price": 25740.50
}
```

### New CHoCH (Change of Character)

```json
{
  "eventCode": "NEWCHoCH",
  "instrument": "ES",
  "timeframe": "5MinuteTime",
  "datetime": "28.01.2026 14:30:15",
  "barTime": "28.01.2026 14:25:00",
  "structureType": "CHoCH",
  "direction": "Up",
  "swingBar": 120,
  "breakBar": 145,
  "chartBar": 150,
  "price": 5025.50,
  "breakPrice": 5028.25,
  "touchPrice": null
}
```

### New BOS (Break of Structure)

```json
{
  "eventCode": "NEWBoS",
  "instrument": "ES",
  "timeframe": "5MinuteTime",
  "datetime": "28.01.2026 14:45:22",
  "barTime": "28.01.2026 14:40:00",
  "structureType": "BOS",
  "direction": "Up",
  "swingBar": 155,
  "breakBar": 168,
  "chartBar": 170,
  "price": 5032.75,
  "breakPrice": 5035.00,
  "touchPrice": null
}
```

### CHoCH Level Retest

```json
{
  "eventCode": "CHoCHTOUCH",
  "instrument": "ES",
  "timeframe": "5MinuteTime",
  "datetime": "28.01.2026 15:10:05",
  "barTime": "28.01.2026 15:05:00",
  "structureType": "CHoCH",
  "direction": "Up",
  "swingBar": 120,
  "breakBar": 145,
  "chartBar": 185,
  "price": 5025.50,
  "breakPrice": 5028.25,
  "touchPrice": 5026.00
}
```

---

## 🔍 Field Breakdown

### Timestamps

- **datetime:** System clock when webhook was sent (`DateTime.Now`)
  - In live trading: current real-time
  - In Market Replay: time when replay was running
- **barTime:** Actual candle close time from the chart
  - In live trading: matches `datetime` closely
  - In Market Replay: shows the historical bar time

### Instrument & Timeframe

- **instrument:** Trading symbol (e.g., `NQ`, `ES`, `MNQ`, `MES`)
- **timeframe:** Chart timeframe + chart type (e.g., `12RenkoTime`, `5MinuteTime`, `1HourTime`)

---

## 📑 Complete Event Code Reference

### Order Block Events

| Event Code | Description |
|------------|-------------|
| `NEWOBstrong` | New Order Block confirmed as Strong (aligned candle color) |
| `NEWOBweak` | New Order Block confirmed as Weak (not color-aligned) |
| `OBweakTOstrong` | Weak OB upgraded to Strong |
| `OBstrongTOUCH` | Price touched a Strong OB zone |
| `OBweakTOUCH` | Price touched a Weak OB zone |
| `OBvPOCTOUCH` | Price touched the OB's volume POC level |
| `OBtoBB` | OB invalidated and converted to Breaker Block |

### Breaker Block Events

| Event Code | Description |
|------------|-------------|
| `BBTOUCH` | Price touched a Breaker Block zone |
| `BBvPOCTOUCH` | Price touched the Breaker Block's volume POC level |

### Structure Events (CHoCH/BOS)

| Event Code | Description |
|------------|-------------|
| `NEWCHoCH` | Change of Character detected (trend reversal signal) |
| `NEWBoS` | Break of Structure detected (trend continuation signal) |
| `CHoCHTOUCH` | Price retested a CHoCH level |
| `BoSTOUCH` | Price retested a BOS level |

---

## 🎯 Event Type Interpretation

### Order Block Creation Events

| Event | Meaning |
|-------|---------|
| `NEWOBstrong` | OB confirmed with aligned candle color (high conviction) |
| `NEWOBweak` | OB confirmed but candle color not aligned (lower conviction) |
| `OBweakTOstrong` | Previously weak OB now has aligned confirmation |

### Order Block Touch Events

| Event | Meaning |
|-------|---------|
| `OBstrongTOUCH` | Price entered a Strong OB zone - potential reaction area |
| `OBweakTOUCH` | Price entered a Weak OB zone - lower probability reaction |
| `OBvPOCTOUCH` | Price hit the volume POC within an OB - precision level |

### Breaker Block Events

| Event | Meaning |
|-------|---------|
| `OBtoBB` | OB was broken through and converted to Breaker Block (role reversal) |
| `BBTOUCH` | Price returned to a Breaker Block zone |
| `BBvPOCTOUCH` | Price hit the volume POC within a Breaker Block - precision level |

### Structure Events

| Event | Meaning |
|-------|---------|
| `NEWCHoCH` | Trend reversal signal - previous swing high/low broken against trend |
| `NEWBoS` | Trend continuation signal - previous swing high/low broken with trend |
| `CHoCHTOUCH` | Price returned to retest the CHoCH swing level |
| `BoSTOUCH` | Price returned to retest the BOS swing level |

---

## 📐 Structure Event Fields

### Structure-Specific Fields

- **structureType:** Either `CHoCH` or `BOS`
- **direction:** Current market structure direction (`Up`, `Down`, or `Unknown`)
- **swingBar:** Bar index where the swing high/low was formed
- **breakBar:** Bar index where the swing was broken (structure event occurred)
- **price:** Price level of the swing point (the structure level)
- **breakPrice:** Price at which the break occurred
- **touchPrice:** Price when the level was retested (only on touch events, `null` otherwise)

### Order Block-Specific Fields

- **side:** `Support` (bullish OB) or `Resistance` (bearish OB)
- **obBar:** Bar index where the Order Block was originally created
- **obHigh:** Upper boundary of the OB zone
- **obLow:** Lower boundary of the OB zone
- **price:** Trigger price (only present on touch events, `null` for creation events)

---

## 🔧 n8n Webhook Configuration

### Webhook URL Setup

1. Create a Webhook node in n8n (POST method)
2. Copy the webhook URL (e.g., `https://your-n8n.com/webhook/patternaction`)
3. Configure in ATAS indicator settings:
   - Enable the **Webhook URL** checkbox
   - Paste the URL into the Webhook URL field

### Parsing Example - Order Block Events

```javascript
// Parse PatternAction OB webhook
const body = $input.all()[0].json.body;

const eventCode = body.eventCode || '';
const instrument = body.instrument || '';
const timeframe = body.timeframe || '';
const datetime = body.datetime || '';
const barTime = body.barTime || '';
const side = body.side || '';
const obBar = body.obBar ?? '';
const chartBar = body.chartBar ?? '';
const obHigh = body.obHigh != null ? parseFloat(body.obHigh).toFixed(2) : '';
const obLow = body.obLow != null ? parseFloat(body.obLow).toFixed(2) : '';
const price = body.price != null ? parseFloat(body.price).toFixed(2) : '';

return [{
  json: {
    eventCode, instrument, timeframe, datetime, barTime,
    side, obBar, chartBar, obHigh, obLow, price
  }
}];
```

### Parsing Example - Structure Events

```javascript
// Parse PatternAction Structure webhook
const body = $input.all()[0].json.body;

const eventCode = body.eventCode || '';
const instrument = body.instrument || '';
const timeframe = body.timeframe || '';
const datetime = body.datetime || '';
const barTime = body.barTime || '';
const structureType = body.structureType || '';
const direction = body.direction || '';
const swingBar = body.swingBar ?? '';
const breakBar = body.breakBar ?? '';
const chartBar = body.chartBar ?? '';
const price = body.price != null ? parseFloat(body.price).toFixed(2) : '';
const breakPrice = body.breakPrice != null ? parseFloat(body.breakPrice).toFixed(2) : '';
const touchPrice = body.touchPrice != null ? parseFloat(body.touchPrice).toFixed(2) : '';

return [{
  json: {
    eventCode, instrument, timeframe, datetime, barTime,
    structureType, direction, swingBar, breakBar, chartBar,
    price, breakPrice, touchPrice
  }
}];
```

### Filter by Event Category

```javascript
// Route based on event type
const obEvents = ['NEWOBstrong', 'NEWOBweak', 'OBweakTOstrong',
                  'OBstrongTOUCH', 'OBweakTOUCH', 'OBvPOCTOUCH', 'OBtoBB'];
const bbEvents = ['BBTOUCH', 'BBvPOCTOUCH'];
const structureEvents = ['NEWCHoCH', 'NEWBoS', 'CHoCHTOUCH', 'BoSTOUCH'];

const code = $json.eventCode;

if (obEvents.includes(code)) {
  return { json: { ...items[0].json, category: 'OrderBlock' } };
} else if (bbEvents.includes(code)) {
  return { json: { ...items[0].json, category: 'BreakerBlock' } };
} else if (structureEvents.includes(code)) {
  return { json: { ...items[0].json, category: 'Structure' } };
}
return null;
```

### Filter Structure Events Only

```javascript
// Only process CHoCH and BOS events
const structureEvents = ['NEWCHoCH', 'NEWBoS', 'CHoCHTOUCH', 'BoSTOUCH'];
if (structureEvents.includes($json.eventCode)) {
  return $input.item;
} else {
  return null;
}
```

---

## 📱 Discord Alert Examples

### Order Block Alert

```
PATTERNACTION - ORDER BLOCK
event: Strong OB Touch
bar time: 28.01.2026 14:10:45
sent at: 28.01.2026 15:58:39
instrument: NQ
timeframe: 12Renko
side: Support
OB zone: 25737.25 - 25740.50
price: 25740.50
OB bar: 8272  |  chart bar: 8278
--------------------------------------------
```

### Structure Alert

```
PATTERNACTION - STRUCTURE
event: CHoCH (Change of Character)
bar time: 28.01.2026 14:25:00
sent at: 28.01.2026 14:30:15
instrument: ES
timeframe: 5Min
direction: Up
swing level: 5025.50
break price: 5028.25
swing bar: 120  |  break bar: 145
--------------------------------------------
```

---

## ⚙️ Event Lifecycle Tracking

### Order Block Lifecycle

A typical Order Block lifecycle produces webhooks in this sequence:

```
1. NEWOBweak      → OB detected, not yet color-aligned
2. OBweakTOstrong → Candle confirmed alignment
3. OBstrongTOUCH  → Price returned to the zone
4. OBvPOCTOUCH    → Price hit the vPOC inside the OB
5. OBtoBB         → Price broke through → Breaker Block
6. BBTOUCH        → Price retested the Breaker Block
7. BBvPOCTOUCH    → Price hit the vPOC inside the BB
```

Common OB paths:

- **Strong setup:** `NEWOBstrong` → `OBstrongTOUCH`
- **Upgrade path:** `NEWOBweak` → `OBweakTOstrong` → `OBstrongTOUCH`
- **Invalidation:** `NEWOBstrong` → `OBtoBB` → `BBTOUCH`
- **Quick touch:** `NEWOBweak` → `OBweakTOUCH`

### Structure Event Lifecycle

Market structure events follow this pattern:

```
Uptrend established:
1. NEWCHoCH (direction: Up)   → First swing high broken, trend reversal
2. NEWBoS (direction: Up)     → Higher low broken, trend continuation
3. BoSTOUCH                   → Price retests the BOS level
4. NEWCHoCH (direction: Down) → Swing low broken, trend reversal

Downtrend established:
1. NEWCHoCH (direction: Down) → First swing low broken, trend reversal
2. NEWBoS (direction: Down)   → Lower high broken, trend continuation
3. CHoCHTOUCH                 → Price retests the CHoCH level
```

---

## 🛠️ Troubleshooting

### No Webhook Messages Received

- Verify webhook URL is correct in ATAS indicator settings
- Confirm the **Webhook URL** checkbox is enabled (not just the URL field)
- Check indicator is loaded on a chart with live or replay data
- Test with webhook.site first

### Price/touchPrice Field is null

- This is expected for creation events (`NEWOBstrong`, `NEWOBweak`, `OBweakTOstrong`, `OBtoBB`, `NEWCHoCH`, `NEWBoS`)
- Price fields are only populated on touch events when price enters the zone

### barTime and datetime Show Same Value

- This is normal during live trading
- They differ during Market Replay (barTime = historical, datetime = current system clock)

### Structure Events Not Firing

- Ensure **Enable Structure (CHoCH/BOS)** is enabled in the indicator settings
- Structure events require swing points to be detected first
- Check that sufficient price history is loaded

### Too Many Messages

- Focus on specific event types using a filter node
- Use larger timeframes (fewer events = fewer webhooks)
- Filter by direction if you only trade one trend direction

---

## 📚 Related Documentation

- [semaPHorek Webhook Format](../Webhook-Reference/semaPHorek-Webhook-Format.md)
- [Your First Webhook Receiver](../Getting-Started/02-Your-First-Webhook.md)
- [Testing Your Webhooks](../Getting-Started/03-Testing-Webhooks.md)

---

*Last Updated: January 28, 2026*
*Version: 2.13 - Structure Webhooks*
