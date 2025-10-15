# semaPHorek - Webhook Format Reference

> **Traffic-Light System for Order Flow Intelligence**
> 9-condition footprint analysis simplified to go/stop/caution signals

---

## 📊 Message Format

```
DD/MM/YYYY HH:MM:SS.fff INSTRUMENT TIMEFRAME LIGHTS STATUS CONDITIONS BARNUMBER OPEN HIGH LOW CLOSE VPOC
```

---

## 📋 Example Message

```
25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75
```

---

## 🔍 Field Breakdown

### Date & Time
- **Date:** `DD/MM/YYYY` format (e.g., `25/09/2025`)
- **Time:** `HH:MM:SS.fff` with milliseconds (e.g., `18:27:08.861`)
- **Timezone:** Always Prague time (CET/CEST)

### Instrument & Timeframe
- **Instrument:** Trading symbol (e.g., `MNQ`, `ES`, `NQ`)
- **Timeframe:** Chart timeframe (e.g., `4Renko`, `5m`, `1h`)

### Signal Information
- **Lights:** Number of valid conditions met (`0-9`)
  - 9 = All conditions met (strongest signal)
  - 0 = No conditions met
- **Status:** Bar state
  - `C` = Candle closed (completed bar)
  - `O` = Bar open/forming (real-time update)

### Binary Conditions (9 digits: `0` or `1`)
Position-based representation of 9 conditions:

| Position | Condition | Description |
|----------|-----------|-------------|
| 1 | Absorption Size | Large absorption detected |
| 2 | Absorption Amount | Multiple absorption clusters |
| 3 | PowerBar Volume | Institutional volume signature |
| 4 | Absolute Volume | Volume threshold exceeded |
| 5 | Delta | Delta divergence detected |
| 6 | Finished Business | Zero contracts at extreme |
| 7 | Diagonal Imbalances | Imbalance zones present |
| 8 | Smart Money Tape | Tape reading pattern |
| 9 | vPOC Positioning | Volume Point of Control location |

**Example:** `111111101`
- Positions 1-7: ✅ Met (all conditions satisfied)
- Position 8: ✅ Met
- Position 9: ❌ Not met (vPOC positioning doesn't qualify)

**Result:** 8/9 conditions = 8 Lights

### Bar Data
- **Bar Number:** Sequential bar count (e.g., `37748`)
- **OHLC:** Open, High, Low, Close prices
  - Open: `24576.75`
  - High: `24577.50`
  - Low: `24576.25`
  - Close: `24577.50`
- **vPOC:** Volume Point of Control price level (`24576.75`)

---

## 🎯 Signal Quality Interpretation

### Green Light (7-9 Lights)
**Strong institutional footprint detected**
- Multiple confluence conditions
- High-probability setup
- Consider entry preparation

### Yellow Light (4-6 Lights)
**Moderate signal strength**
- Some conditions met
- Context-dependent evaluation
- Wait for additional confirmation

### Red Light (0-3 Lights)
**Weak or no signal**
- Few conditions satisfied
- Low-probability environment
- Stay flat or reduce risk

---

## 🔧 n8n Webhook Configuration

### Webhook URL Setup
1. Create webhook node in n8n
2. Copy webhook URL (e.g., `https://your-n8n.com/webhook/semaphorek`)
3. Configure in ATAS indicator settings:
   - Enable Webhook
   - Paste URL
   - Choose trigger: Bar Close (`C`) or Real-time (`O`)

### Parsing Example (n8n Code Node)

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

### Filter by Signal Strength

```javascript
// Only process strong signals (7+ lights)
if ($json.lights >= 7) {
  return $input.item;
} else {
  return null; // Ignore weak signals
}
```

---

## 📱 Telegram Alert Example

**Format for trading alerts:**

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

## ⚙️ Advanced: Condition Parsing

To extract individual condition states:

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

## 🛠️ Troubleshooting

### No Webhook Messages Received
- Verify webhook URL is correct in ATAS settings
- Check indicator is enabled on chart
- Confirm "Enable Webhook" checkbox is ON
- Test with webhook.site first (see [Testing Guide](../Getting-Started/03-Testing-Webhooks.md))

### Messages Incomplete or Garbled
- Verify n8n webhook node expects `text/plain` content type
- Check firewall isn't blocking ATAS outbound connections
- Confirm no special characters in webhook URL

### Too Many Messages
- Change trigger from Real-time (`O`) to Bar Close (`C`) only
- Add filter node in n8n (only process 7+ lights)
- Increase chart timeframe (fewer bars = fewer messages)

---

## 📚 Related Documentation

- [Your First Webhook Receiver](../Getting-Started/02-Your-First-Webhook.md)
- [Testing Your Webhooks](../Getting-Started/03-Testing-Webhooks.md)
- [Common Issues FAQ](../Troubleshooting/Common-Issues-FAQ.md)

---

*Last Updated: October 15, 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
