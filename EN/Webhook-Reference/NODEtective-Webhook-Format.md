# NODEtective (Ultra) - Webhook Format Reference

> **Volume Profile Node Detection Intelligence**
> Automated HVN/LVN line and zone detection with proximity and touch alerts

---

## 📊 Message Format

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

**Note:** Field names use PascalCase (capital first letter), unlike PatternAction which uses camelCase.

---

## 📋 Example Messages

### Direct Line Touch
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

### Zone Proximity Alert
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

## 🔍 Field Breakdown

### Timestamp
- **DateTime:** UTC timestamp in ISO 8601 format (`DateTime.UtcNow`)
  - Always UTC, not local time
  - Example: `2026-01-27T15:42:18.1234567Z`

### Instrument & Timeframe
- **Instrument:** Trading symbol (e.g., `NQ`, `ES`, `MNQ`, `MES`)
- **Timeframe:** Chart timeframe + chart type (e.g., `12RenkoTime`, `5MinTime`)

### Event Type

| Field | Values | Description |
|-------|--------|-------------|
| **LineOrZone** | `Line` / `Zone` | Whether the alert was triggered by a node line or a zone boundary |
| **Node** | `HVN` / `LVN` | High Volume Node or Low Volume Node |

This gives 4 possible combinations:

| LineOrZone | Node | Meaning |
|------------|------|---------|
| `Line` | `HVN` | Price touched/approached the HVN line (volume peak) |
| `Line` | `LVN` | Price touched/approached the LVN line (volume valley) |
| `Zone` | `HVN` | Price entered/approached the HVN zone (high volume area) |
| `Zone` | `LVN` | Price entered/approached the LVN zone (low volume gap) |

### Price Data
- **Price_Touched:** The node line price or zone boundary price that was touched/approached

### Proximity Information
- **IsProximity:** `true` if price is near but hasn't touched yet; `false` if direct touch
- **DistanceTicks:** How many ticks away from the target (0 = direct touch)
- **ProximitySettingTicks:** The configured proximity threshold in ATAS indicator settings

---

## 🎯 Alert Logic

### Touch vs. Proximity

**Touch (DistanceTicks = 0):**
- Price bar's High/Low range directly intersects the line or zone
- `IsProximity` = `false`

**Proximity (DistanceTicks > 0):**
- Price is within the configured `ProximityTicks` distance but hasn't touched
- `IsProximity` = `true`
- Only fires if `Proximity (ticks)` setting > 0 in ATAS

### Deduplication
- Each line/zone fires only **once** per recalculation cycle
- Alert keys are tracked internally (e.g., `L:HVN:25741.25` or `Z:LVN:25700.00:25710.00`)
- Minimum 300ms interval between alerts

---

## 🔧 n8n Webhook Configuration

### Webhook URL Setup
1. Create a Webhook node in n8n (POST method)
2. Copy the webhook URL (e.g., `https://your-n8n.com/webhook/nodetective`)
3. Configure in ATAS indicator settings:
   - Set **Enable Alerts** to ON
   - Paste URL into **Webhook URL** field
   - Optionally set **Proximity (ticks)** for early warning alerts

### Parsing Example (n8n Code Node)

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

### Filter by Node Type

```javascript
// Only process HVN touches (ignore LVN)
if ($json.node === 'HVN') {
  return $input.item;
} else {
  return null;
}
```

### Filter: Direct Touches Only

```javascript
// Ignore proximity alerts, only process actual touches
if (!$json.isProximity) {
  return $input.item;
} else {
  return null;
}
```

---

## 📱 Discord Alert Example

**Formatted code-block message:**

```
NODETECTIVE
event: Line HVN TOUCH
datetime: 2026-01-27T15:42:18Z
instrument: NQ
timeframe: 12Renko
price: 25741.25
distance: 0 ticks
--------------------------------------------
```

**Proximity alert:**

```
NODETECTIVE
event: Zone LVN PROXIMITY
datetime: 2026-01-27T15:43:05Z
instrument: NQ
timeframe: 12Renko
price: 25728.50
distance: 3 ticks (setting: 5)
--------------------------------------------
```

---

## ⚙️ Advanced: Understanding HVN vs LVN

### HVN (High Volume Node)
- **What:** Price level where significant volume accumulated
- **Trading meaning:** Acts as magnet/support/resistance — price tends to gravitate toward and consolidate at HVN
- **Alert use:** Expect price to slow down, consolidate, or reverse

### LVN (Low Volume Node)
- **What:** Price level with minimal volume (gap in profile)
- **Trading meaning:** Price moves quickly through LVN — acts as transition zone
- **Alert use:** Expect fast price movement through this level

### Zones
- Zones expand around each node using standard deviation (`kZ` parameter)
- HVN zones = areas of high volume concentration
- LVN zones = areas of low volume (price rejection zones)

---

## 🛠️ Troubleshooting

### No Webhook Messages Received
- Verify **Enable Alerts** is ON in ATAS indicator settings
- Confirm webhook URL is entered in the **Webhook URL** field
- Check that the indicator is loaded on a chart with volume profile data
- Test with webhook.site first

### Too Many Alerts
- Set **Proximity (ticks)** to 0 (only direct touches fire)
- Use a filter node in n8n to only process `HVN` or `LVN` (not both)
- Use larger Sensitivity value (fewer nodes detected = fewer alerts)

### Alerts Fire Only Once
- This is by design — each node/zone fires once per recalculation
- When the profile recalculates (new bar), alert keys reset
- This prevents spam from the same level being touched repeatedly

### DateTime is UTC, Not Local Time
- NODEtective sends `DateTime.UtcNow` in ISO 8601 format
- Convert to local time in n8n if needed:
  ```javascript
  const local = new Date(body.DateTime).toLocaleString('de-DE', {timeZone: 'Europe/Prague'});
  ```

---

## 📚 Related Documentation

- [PatternAction Webhook Format](../Webhook-Reference/PatternAction-Webhook-Format.md)
- [semaPHorek Webhook Format](../Webhook-Reference/semaPHorek-Webhook-Format.md)
- [Your First Webhook Receiver](../Getting-Started/02-Your-First-Webhook.md)
- [Testing Your Webhooks](../Getting-Started/03-Testing-Webhooks.md)

---

*Last Updated: January 27, 2026*
*Pavel Horák - ATAS Platform | Expert Trading Automation Architect | 5D Lab Pioneer*
