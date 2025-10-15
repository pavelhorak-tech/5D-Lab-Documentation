# Your First Webhook Receiver

> **Build your first n8n workflow to receive ATAS indicator webhooks**
> Step-by-step guide from blank canvas to working webhook receiver

---

## 🎯 What You'll Build

**Simple webhook receiver that:**
1. Listens for ATAS indicator signals
2. Receives webhook message
3. Displays received data in n8n

**Time Required:** 5-10 minutes
**Difficulty:** Beginner
**Prerequisites:** [n8n account created](01-Creating-n8n-Account.md)

---

## 📋 Step 1: Create New Workflow

### Open n8n Dashboard
1. Log in to [n8n.io](https://n8n.io)
2. Click **"Workflows"** in left sidebar
3. Click **"New Workflow"** button (top right)

### Name Your Workflow
1. Click workflow name at top (default: "My workflow")
2. Rename to: `semaPHorek - First Test`
3. Press Enter (workflow auto-saves)

---

## 🔌 Step 2: Add Webhook Node

### Add Trigger Node
1. Click **"+" button** in center of canvas
2. Search box appears - type: `webhook`
3. Click **"Webhook"** under "Trigger" section
4. Webhook node appears on canvas

### Configure Webhook Node
Click the webhook node to open settings panel:

**HTTP Method:**
- Keep default: `POST`
- ATAS sends webhook data via POST requests

**Path:**
- Enter: `semaphorek-test`
- This becomes part of your webhook URL
- Use descriptive paths (helps organize multiple webhooks later)

**Authentication:**
- Keep: `None`
- We'll add security in Month 2+

**Respond:**
- Keep default: `Immediately`
- Confirms message received to ATAS

### Get Your Webhook URL
After configuring, webhook node shows:

**Production URL:** (permanent, use this for ATAS)
```
https://your-username.app.n8n.cloud/webhook/semaphorek-test
```

**Test URL:** (temporary, disappears after one execution)
```
https://your-username.app.n8n.cloud/webhook-test/semaphorek-test
```

**Copy Production URL** - you'll paste this in ATAS indicator settings

---

## 🎨 Step 3: Configure ATAS Indicator

### Open Indicator Settings
1. Open **ATAS platform**
2. Add **semaPHorek Ultra** indicator to chart
3. Right-click indicator name (top-left of chart)
4. Select **"Settings"**

### Find Webhook Section
Scroll down in settings panel to **"Webhook"** section

### Configure Webhook Settings

**Enable Webhook:**
- ✅ Check the checkbox
- This activates webhook functionality

**Webhook URL:**
- Paste your **n8n Production URL**
- Example: `https://your-username.app.n8n.cloud/webhook/semaphorek-test`
- ⚠️ Make sure no extra spaces at start or end

**Trigger:**
- Select: **"Bar Close (C)"**
- Webhook fires ONLY when bar closes (not on every tick)
- Reduces message volume, focuses on completed signals

**Click OK** to save settings

---

## ⏳ Step 4: Test Webhook Reception

### Activate n8n Listening
1. Return to n8n workflow
2. Click webhook node
3. Click **"Listen for Test Event"** button (if available)
4. Node status shows: "Waiting for webhook call..."

### Trigger Test Message from ATAS
**Option A: Wait for Bar Close**
- Let your chart run normally
- Wait for current bar to close
- Webhook fires automatically

**Option B: Force Quick Test (Faster)**
- Change chart timeframe to **1 minute**
- Wait 1 minute for bar to close
- Faster than waiting on 15m or 1h timeframe

### Verify Reception
When webhook arrives:
- ✅ n8n webhook node shows **green checkmark**
- ✅ Node panel displays received data
- ✅ Timestamp in n8n matches ATAS bar close time

---

## 🔍 Step 5: Inspect Received Data

### View Webhook Data
Click webhook node to see **output panel**:

```json
{
  "headers": {
    "content-type": "text/plain",
    "user-agent": "ATAS/...",
    ...
  },
  "params": {},
  "query": {},
  "body": "25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75"
}
```

### Understand Data Structure
**Key field: `body`** - Contains full webhook message

**Message format:**
```
DATE TIME INSTRUMENT TIMEFRAME LIGHTS STATUS CONDITIONS BARNUMBER OPEN HIGH LOW CLOSE VPOC
```

**Your example might look like:**
```
15/10/2025 14:23:45.123 ES 5m 7 C 111111100 12345 5432.00 5433.50 5431.75 5432.50 5432.25
```

This is **raw data** - we'll parse it in next lessons

---

## ✅ Success Checklist

Verify everything works before proceeding:

- [ ] Webhook node created in n8n
- [ ] Production URL copied
- [ ] ATAS indicator configured with webhook URL
- [ ] "Enable Webhook" checkbox ON
- [ ] Test message received in n8n
- [ ] Webhook data visible in node output panel
- [ ] Message format looks correct (date, instrument, prices visible)

**All checked?** Congratulations! Your first webhook receiver works!

---

## 🎓 What You Learned

✅ Created webhook trigger node in n8n
✅ Configured ATAS indicator to send webhooks
✅ Received and viewed webhook data
✅ Understood basic webhook data structure

---

## 🚀 Next Steps

**You can receive webhooks!** Now let's DO something with them:

### Immediate Next Steps
- [Testing Your Webhooks](03-Testing-Webhooks.md) - Verify with webhook.site, troubleshoot issues
- [semaPHorek Webhook Format](../Webhook-Reference/semaPHorek-Webhook-Format.md) - Understand message structure in detail

### Video Tutorials (Discord #video-tutorials)
- **Video 2:** "Your First Telegram Alert" - Send webhook data to Telegram
- **Video 3:** "Multi-Indicator Confluence" - Combine multiple indicator webhooks

### Build Your Skills
- Add more indicators (Linescope, NODEtective)
- Create multiple webhook receivers
- Start thinking about what YOU want to automate

---

## 🛠️ Troubleshooting

### Webhook Node Shows No Data
**Problem:** ATAS indicator not sending, or wrong URL

**Solutions:**
1. Verify "Enable Webhook" is checked in ATAS
2. Confirm URL copied correctly (no spaces)
3. Try [Testing Guide](03-Testing-Webhooks.md) with webhook.site first
4. Check Windows Firewall isn't blocking ATAS

### Message Received But Empty
**Problem:** Indicator hasn't calculated yet, or wrong configuration

**Solutions:**
1. Wait for chart to fully load (need several bars of data)
2. Confirm indicator is visible on chart (not hidden)
3. Check indicator settings are saved (click OK)
4. Try different bar close (wait for next bar)

### URL Too Long or Breaks
**Problem:** URL formatting issue in ATAS settings

**Solutions:**
1. Don't add `http://` or `https://` manually (n8n provides full URL)
2. Copy entire URL from n8n (including https://)
3. Don't add extra slashes at end
4. If URL is truncated, use shorter path name in webhook node

### Multiple Messages at Once
**Problem:** Real-time updates enabled instead of bar close only

**Solutions:**
1. Change ATAS trigger from "Real-time (O)" to "Bar Close (C)"
2. Reduces message volume significantly
3. Focuses on completed signals only

---

## 💡 Pro Tips

### Organize Webhook Paths
Use naming convention for multiple indicators:
```
/webhook/semaphorek-mnq-4renko
/webhook/linescope-es-5m
/webhook/nodetective-nq-15m
```

**Benefits:**
- Know which indicator by URL alone
- Easy to track in n8n execution logs
- Professional organization from day one

### Save Workflow Regularly
n8n auto-saves, but if you make big changes:
1. Click **"Save"** button explicitly
2. Or press **Ctrl+S** (Windows) / **Cmd+S** (Mac)
3. Look for green checkmark confirming save

### Duplicate for Experimentation
Before modifying working workflow:
1. Right-click workflow in list
2. Select **"Duplicate"**
3. Rename to `semaPHorek - First Test (BACKUP)`
4. Experiment safely without breaking working version

### Test URL vs Production URL
**Test URL:**
- Temporary (disappears after execution)
- Good for initial testing
- Don't configure ATAS with this

**Production URL:**
- Permanent (stays active)
- Use this for ATAS indicator settings
- Can receive webhooks 24/7

---

## 📚 Related Documentation

- [Creating Your n8n Account](01-Creating-n8n-Account.md)
- [Testing Your Webhooks](03-Testing-Webhooks.md)
- [semaPHorek Webhook Format](../Webhook-Reference/semaPHorek-Webhook-Format.md)

---

## 🎬 Video Tutorial

Watch **Video 1: "n8n Basics"** in Discord #video-tutorials for visual walkthrough of webhook node creation.

Watch **Video 2: "Your First Telegram Alert"** to see how to USE this webhook data (send alerts, log to database, etc.)

---

*Last Updated: October 15, 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
*5D Lab - Systematic Trading Intelligence*
