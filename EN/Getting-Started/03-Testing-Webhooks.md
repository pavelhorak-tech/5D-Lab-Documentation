# Testing Your Webhooks

> **Always test webhooks BEFORE connecting live indicators**
> Verify your setup works with simple test messages first

---

## 🎯 Why Test First?

**Prevent frustration:**
- Confirm n8n receives messages correctly
- Verify ATAS can send webhooks (firewall, network)
- Debug issues without waiting for trading signals
- Build confidence in your setup

**Test → Verify → Go Live** (never skip testing!)

---

## 🧪 Method 1: webhook.site (Easiest)

### What is webhook.site?
Free online tool that creates temporary webhook URLs and displays incoming messages in real-time. Perfect for verifying ATAS can send webhooks.

### Step 1: Get Test URL
1. Go to [https://webhook.site](https://webhook.site)
2. You'll see a **unique URL** generated automatically
3. **Copy this URL** (looks like: `https://webhook.site/abc123-def456...`)

### Step 2: Configure ATAS Indicator
1. Open ATAS platform
2. Add indicator to chart (e.g., semaPHorek Ultra)
3. Open indicator **Settings**
4. Find **Webhook** section
5. **Enable Webhook** checkbox: ✅ ON
6. **Webhook URL:** Paste webhook.site URL
7. **Trigger:** Select "Bar Close" (C)
8. Click **OK**

### Step 3: Generate Test Signal
**Option A: Wait for Bar Close**
- Let chart run normally
- Wait for bar to close
- webhook.site should show incoming message

**Option B: Force Signal (Faster)**
- Change timeframe to 1 minute
- Wait 1 minute for bar close
- Immediate test without waiting

### Step 4: Verify Message
On webhook.site, you should see:
```
25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75
```

**Success Indicators:**
- ✅ Message appears in webhook.site log
- ✅ Timestamp matches current time
- ✅ Instrument/timeframe matches your chart
- ✅ Data looks complete (no missing fields)

### Troubleshooting webhook.site
**No message received?**
- Check "Enable Webhook" is ON in ATAS settings
- Verify URL copied correctly (no extra spaces)
- Check Windows Firewall isn't blocking ATAS
- Try different indicator/chart (confirm ATAS can send at all)

---

## 🧪 Method 2: n8n Test Webhook

### Step 1: Create Webhook Node in n8n
1. Open your n8n workflow
2. Click **"+" button** to add node
3. Search for **"Webhook"**
4. Select **"Webhook"** trigger node
5. Node appears on canvas

### Step 2: Configure Webhook Node
1. Click webhook node to open settings
2. **HTTP Method:** `POST` (default)
3. **Path:** Choose descriptive path (e.g., `semaphorek-test`)
4. **Authentication:** None (for testing)
5. Click **"Execute Node"** button

### Step 3: Copy Webhook URL
n8n shows **Production URL** and **Test URL**:
```
Production: https://your-n8n.app/webhook/semaphorek-test
Test: https://your-n8n.app/webhook-test/semaphorek-test
```

**Use Test URL** for initial testing (disappears after execution)

### Step 4: Configure ATAS Indicator
Same as Method 1:
1. Open indicator settings in ATAS
2. Enable Webhook
3. Paste **n8n Test URL**
4. Set trigger to "Bar Close"
5. Click OK

### Step 5: Wait for Webhook Node
1. n8n webhook node shows **"Waiting for webhook call..."**
2. Let ATAS chart run until bar closes
3. When webhook arrives, node executes
4. **Output data** appears in node panel

### Step 6: Verify Data Structure
Click webhook node to see received data:
```json
{
  "headers": {...},
  "params": {},
  "query": {},
  "body": "25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75"
}
```

**Success:** `body` field contains full webhook message

---

## 🧪 Method 3: Manual Webhook Testing (Advanced)

### Using cURL (Command Line)
Test your n8n webhook without ATAS:

```bash
curl -X POST https://your-n8n.app/webhook/semaphorek-test \
  -H "Content-Type: text/plain" \
  -d "25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75"
```

**When to use:**
- Test n8n workflow logic without ATAS
- Verify n8n can receive webhooks at all
- Debug parsing issues with known data

### Using Postman (GUI Tool)
1. Download [Postman](https://www.postman.com/downloads/) (free)
2. Create **New Request**
3. Set method to **POST**
4. Enter webhook URL
5. **Body tab** → Select "raw" → Type "Text"
6. Paste sample webhook message
7. Click **Send**

**Result:** n8n receives test message, workflow executes

---

## ✅ Verification Checklist

Before connecting live indicators to n8n:

- [ ] Tested with webhook.site successfully
- [ ] Verified ATAS can send webhooks (firewall/network OK)
- [ ] Created webhook node in n8n
- [ ] Received test message in n8n successfully
- [ ] Verified message format matches indicator documentation
- [ ] Confirmed all fields present (date, time, instrument, etc.)

**All checkboxes ✅?** You're ready to build real workflows!

---

## 🎓 Next Steps

**You've confirmed webhooks work!** Now build your first automation:

- [semaPHorek Webhook Reference](../Webhook-Reference/semaPHorek-Webhook-Format.md) - Parse and use webhook data
- Video 2: "Your First Telegram Alert" (Discord #video-tutorials)
- Video 3: "Multi-Indicator Confluence Basics" (Discord #video-tutorials)

---

## 🛠️ Common Testing Issues

### webhook.site Shows Nothing
**Possible causes:**
- Webhook disabled in ATAS indicator settings
- URL copied incorrectly (extra spaces, wrong URL)
- Windows Firewall blocking ATAS outbound connections
- Indicator not on active chart

**Solutions:**
1. Verify "Enable Webhook" checkbox is ON
2. Copy URL again carefully (no trailing spaces)
3. Check Windows Firewall settings (allow ATAS.exe)
4. Confirm indicator is visible on chart (not hidden)

### n8n Webhook Node Never Triggers
**Possible causes:**
- Using Production URL instead of Test URL
- Webhook node not in "listening" state
- ATAS sending to wrong URL
- n8n.io cloud service issue

**Solutions:**
1. Click "Execute Node" button on webhook node (starts listening)
2. Use Test URL for initial testing (easier to debug)
3. Verify exact URL in ATAS settings (copy again)
4. Try webhook.site first (confirms ATAS side works)

### Message Received But Incomplete
**Possible causes:**
- Indicator still calculating (not enough data)
- Wrong content-type setting
- Message encoding issue

**Solutions:**
1. Wait for chart to fully load (several bars of data)
2. Confirm webhook node expects `text/plain` content type
3. Check indicator version (ensure latest Ultra version)

### Firewall Blocks Webhooks
**Symptoms:**
- webhook.site shows nothing
- ATAS doesn't show any errors
- Other internet features work fine

**Solutions:**
1. **Windows Defender Firewall:**
   - Open Windows Security
   - Firewall & network protection
   - Allow an app through firewall
   - Find ATAS.exe
   - Enable for Private and Public networks

2. **Third-party Firewall:**
   - Check firewall logs for blocked ATAS connections
   - Add ATAS.exe to allowed applications
   - Allow outbound HTTPS (port 443)

---

## 💡 Testing Best Practices

### Always Test on Low Timeframe First
- Use 1-minute chart for testing (fast bar closes)
- Don't wait 1 hour for test on 1h timeframe
- Switch back to trading timeframe after confirming it works

### Test Each Indicator Separately
- Don't configure 5 indicators at once
- Test one, verify it works, then add next
- Easier to debug if something breaks

### Keep webhook.site Tab Open
- During initial setup, keep webhook.site monitoring
- Even after n8n works, use it to verify ATAS still sending
- Quick check if workflow stops working later

### Document Your Webhook URLs
Keep list in notepad/Obsidian:
```
semaPHorek MNQ 4Renko: https://your-n8n.app/webhook/semaphorek-mnq
Linescope ES 5m: https://your-n8n.app/webhook/linescope-es
NODEtective NQ 15m: https://your-n8n.app/webhook/nodetective-nq
```

**Why?** Easy to reconfigure if settings reset

---

## 📚 Related Documentation

- [Creating Your n8n Account](01-Creating-n8n-Account.md)
- [Your First Webhook Receiver](02-Your-First-Webhook.md)
- [Common Issues FAQ](../Troubleshooting/Common-Issues-FAQ.md)
- [semaPHorek Webhook Format](../Webhook-Reference/semaPHorek-Webhook-Format.md)

---

*Last Updated: October 15, 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
*5D Lab - Systematic Trading Intelligence*
