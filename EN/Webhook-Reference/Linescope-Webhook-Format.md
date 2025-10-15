# Linescope Ultra - Webhook Format Reference

**Indicator:** Linescope Ultra
**Version:** 2.3 (September 22, 2025)
**Format:** JSON

---

## Overview

Linescope Ultra sends webhooks when significant level events occur:
- First touches of key levels
- Broken level retests
- Flipped level touches
- New TPO tails appearing (buying/selling tails)

Each webhook contains complete context about the event, level details, and formatted message.

---

## Webhook Configuration

**Setting Location:** Alerts section → "Webhook URL"

**Enable Steps:**
1. Check "Enable" box for Webhook URL
2. Enter your n8n webhook URL
3. All configured level events will trigger webhooks automatically

---

## JSON Payload Structure

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

## Field Breakdown

### Root Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `date` | string | Date in YYYY-MM-DD format | `"2025-10-15"` |
| `time` | string | Time in HH:mm:ss format | `"14:30:00"` |
| `instrument` | string | Trading instrument symbol | `"MNQ"`, `"NQ"`, `"ES"` |
| `timeframe` | string | Chart timeframe | `"4 Renko"`, `"5 min"` |
| `type` | string | Event type (see below) | `"first touch"` |
| `price` | number | Level price where event occurred | `24575.50` |
| `message` | string | Human-readable formatted message | See examples below |

### Level Object

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `label` | string | Level label/name | `"PDH"`, `"PWH"`, `"VPOC"` |
| `source` | string | Level source type | `"OHLC"`, `"VWAP"`, `"VolumeProfile"`, `"TPOProfile"`, `"Sessions"` |
| `period` | string | Period span | `"Day"`, `"Week"`, `"Month"` |
| `ltype` | string | Level type | `"High"`, `"Low"`, `"Open"`, `"Close"`, `"VAH"`, `"VAL"`, `"POC"`, `"BT"`, `"ST"` |

---

## Event Types

### 1. **first touch**
Level touched for the first time after appearing.

**Example:**
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
Previously broken level touched again (retest).

**Example:**
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
Level that flipped from support to resistance (or vice versa) is touched.

**Example:**
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
New TPO buying tail detected (current day composite).

**Example:**
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
New TPO selling tail detected (current day composite).

**Example:**
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

## Level Sources

| Source | Description | Example Labels |
|--------|-------------|----------------|
| `OHLC` | Period High/Low/Open/Close | `PDH`, `PWL`, `PMO`, `PDC` |
| `VWAP` | Volume Weighted Average Price levels | `VWAP`, `VWAP+1SD`, `VWAP-2SD` |
| `VolumeProfile` | Volume Profile levels | `VPOC`, `VAH`, `VAL` |
| `TPOProfile` | Time Price Opportunity levels | `TPOC`, `VAH`, `VAL`, `BT`, `ST` |
| `Sessions` | Session extremes (Asia/Europe/US) | `AsiaH`, `EuropeL`, `USH` |
| `InitialBalance` | Initial Balance ranges | `IBH`, `IBL` |

---

## Level Types

| Type | Description |
|------|-------------|
| `High` | Period high |
| `Low` | Period low |
| `Open` | Period open |
| `Close` | Period close |
| `POC` | Point of Control (max volume/TPO) |
| `VAH` | Value Area High |
| `VAL` | Value Area Low |
| `BT` | Buying Tail (TPO) |
| `ST` | Selling Tail (TPO) |
| `BTcd` | Buying Tail (Current Day) |
| `STcd` | Selling Tail (Current Day) |

---

## Touch Direction Arrows

The `message` field includes visual indicators:

| Arrow | Meaning |
|-------|---------|
| ⬆️ | Candle closed above level (bullish touch) |
| ⬇️ | Candle closed below level (bearish touch) |
| ↔️ | Candle closed at level (neutral) |

---

## Usage Examples

### Example 1: Telegram Alert on PDH Touch

**n8n Workflow:**
```
Webhook → IF node (check type="first touch" AND label="PDH") → Telegram
```

**Filter Expression:**
```javascript
{{ $json.type === "first touch" && $json.level.label === "PDH" }}
```

**Telegram Message:**
```
🔔 {{ $json.level.label }} touched at {{ $json.price }}
{{ $json.instrument }} {{ $json.timeframe }}
{{ $json.message }}
```

### Example 2: Log All Tail Appearances to Google Sheets

**n8n Workflow:**
```
Webhook → IF node (check type contains "tail appeared") → Google Sheets
```

**Filter Expression:**
```javascript
{{ $json.type.includes("tail appeared") }}
```

**Sheet Columns:**
- Date: `{{ $json.date }}`
- Time: `{{ $json.time }}`
- Instrument: `{{ $json.instrument }}`
- Type: `{{ $json.type }}`
- Price: `{{ $json.price }}`
- Label: `{{ $json.level.label }}`

### Example 3: Track Broken Level Retests

**n8n Workflow:**
```
Webhook → IF node (check type="broken level touch") → Database + Telegram
```

**Use Case:** Monitor when previously broken levels are retested - often significant for trend continuation/reversal.

---

## Common Level Labels

### Daily Levels
- `PDH` - Previous Day High
- `PDL` - Previous Day Low
- `PDO` - Previous Day Open
- `PDC` - Previous Day Close

### Weekly Levels
- `PWH` - Previous Week High
- `PWL` - Previous Week Low
- `PWO` - Previous Week Open
- `PWC` - Previous Week Close

### Monthly Levels
- `PMH` - Previous Month High
- `PML` - Previous Month Low
- `PMO` - Previous Month Open
- `PMC` - Previous Month Close

### Profile Levels
- `VPOC` - Volume Point of Control
- `TPOC` - Time Price Opportunity Point of Control
- `VAH` - Value Area High
- `VAL` - Value Area Low

### Session Levels
- `AsiaH`, `AsiaL` - Asia session extremes
- `EuropeH`, `EuropeL` - Europe session extremes
- `USH`, `USL` - US session extremes

### Initial Balance
- `IBH`, `IBL` - Initial Balance High/Low (various periods)

---

## Troubleshooting

### No webhooks received

1. **Check Webhook URL is enabled:**
   - Settings → Alerts → Webhook URL → Enable checkbox ✓

2. **Verify URL is correct:**
   - Test with webhook.site first
   - Check for HTTPS (not HTTP)

3. **Confirm level alerts are enabled:**
   - Each level type has individual Alert toggle
   - Webhook fires when level event occurs

4. **Check n8n webhook node:**
   - Must be "Webhook" node (not HTTP Request)
   - Path should match indicator URL
   - Method: POST
   - Response: Return 200 OK

### Duplicate webhooks

Linescope has built-in deduplication per bar. You shouldn't receive duplicate events for the same bar/level/event combination.

### Missing level data

If `level` fields are `null`:
- Event may be from a level without full metadata
- Check that level source is configured properly in indicator

---

## Deduplication Logic

Linescope prevents duplicate webhooks using this key:
```
{bar}|{type}|{price}|{levelLabel}
```

Once a specific event fires on a bar, it won't fire again until the next bar, even if price touches the level multiple times within the same candle.

---

## Performance Notes

- Webhooks are sent asynchronously (non-blocking)
- 5-second timeout per webhook request
- Failed webhook sends don't stop indicator execution
- No retry logic - if webhook fails, event is lost

---

## Integration Tips

### 1. Multi-Timeframe Confluence
Track same level touched across multiple timeframes:
```javascript
// Store touches in context
const key = `${$json.level.label}_${$json.price}`;
$context.set(key, $json);
```

### 2. Level Strength Scoring
Count how many times a level holds:
```javascript
// Increment counter on each touch that doesn't break
if ($json.type === "first touch") {
  // Level held - increment strength score
}
```

### 3. Automated Trade Journal
Log every level interaction with market context for later analysis.

---

## Related Documentation

- [Creating Your n8n Account](../Getting-Started/01-Creating-n8n-Account.md)
- [Your First Webhook](../Getting-Started/02-Your-First-Webhook.md)
- [Testing Webhooks](../Getting-Started/03-Testing-Webhooks.md)
- [semaPHorek Webhook Format](semaPHorek-Webhook-Format.md)
- [PatternAction Webhook Format](PatternAction-Webhook-Format.md)

---

**Questions?** Ask in Discord #-chat or #-diskussion

**Found an issue?** DM Pavel Horák

---

*Documentation version: 1.0 | Last updated: October 15, 2025*
