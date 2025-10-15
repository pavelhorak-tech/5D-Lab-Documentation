# Ihr erster Webhook-Empfänger

> **Erstellen Sie Ihren ersten n8n-Workflow zum Empfang von ATAS-Indikator-Webhooks**
> Schritt-für-Schritt-Anleitung von der leeren Arbeitsfläche zum funktionierenden Webhook-Empfänger

---

## 🎯 Was Sie erstellen werden

**Einfacher Webhook-Empfänger, der:**
1. Auf ATAS-Indikator-Signale wartet
2. Webhook-Nachrichten empfängt
3. Empfangene Daten in n8n anzeigt

**Benötigte Zeit:** 5-10 Minuten
**Schwierigkeit:** Anfänger
**Voraussetzungen:** [n8n-Konto erstellt](01-n8n-Konto-erstellen.md)

---

## 📋 Schritt 1: Neuen Workflow erstellen

### n8n-Dashboard öffnen
1. Melden Sie sich bei [n8n.io](https://n8n.io) an
2. Klicken Sie auf **"Workflows"** in der linken Seitenleiste
3. Klicken Sie auf die Schaltfläche **"New Workflow"** (oben rechts)

### Workflow benennen
1. Klicken Sie oben auf den Workflow-Namen (Standard: "My workflow")
2. Umbenennen in: `semaPHorek - First Test`
3. Drücken Sie Enter (Workflow wird automatisch gespeichert)

---

## 🔌 Schritt 2: Webhook-Node hinzufügen

### Trigger-Node hinzufügen
1. Klicken Sie auf die **"+" Schaltfläche** in der Mitte der Arbeitsfläche
2. Ein Suchfeld erscheint - geben Sie ein: `webhook`
3. Klicken Sie auf **"Webhook"** im Bereich "Trigger"
4. Der Webhook-Node erscheint auf der Arbeitsfläche

### Webhook-Node konfigurieren
Klicken Sie auf den Webhook-Node, um das Einstellungspanel zu öffnen:

**HTTP-Methode:**
- Behalten Sie die Standardeinstellung: `POST`
- ATAS sendet Webhook-Daten über POST-Anfragen

**Path:**
- Geben Sie ein: `semaphorek-test`
- Dies wird Teil Ihrer Webhook-URL
- Verwenden Sie beschreibende Pfade (hilft später beim Organisieren mehrerer Webhooks)

**Authentication:**
- Behalten Sie: `None`
- Wir fügen Sicherheit in Monat 2+ hinzu

**Respond:**
- Behalten Sie die Standardeinstellung: `Immediately`
- Bestätigt den Nachrichtenempfang an ATAS

### Ihre Webhook-URL abrufen
Nach der Konfiguration zeigt der Webhook-Node:

**Production URL:** (permanent, verwenden Sie diese für ATAS)
```
https://your-username.app.n8n.cloud/webhook/semaphorek-test
```

**Test URL:** (temporär, verschwindet nach einer Ausführung)
```
https://your-username.app.n8n.cloud/webhook-test/semaphorek-test
```

**Kopieren Sie die Production URL** - Sie werden diese in den ATAS-Indikator-Einstellungen einfügen

---

## 🎨 Schritt 3: ATAS-Indikator konfigurieren

### Indikator-Einstellungen öffnen
1. Öffnen Sie die **ATAS-Plattform**
2. Fügen Sie den **semaPHorek Ultra** Indikator zum Chart hinzu
3. Rechtsklick auf den Indikator-Namen (oben links im Chart)
4. Wählen Sie **"Settings"**

### Webhook-Bereich finden
Scrollen Sie im Einstellungspanel nach unten zum **"Webhook"** Bereich

### Webhook-Einstellungen konfigurieren

**Enable Webhook:**
- ✅ Aktivieren Sie das Kontrollkästchen
- Dies aktiviert die Webhook-Funktionalität

**Webhook URL:**
- Fügen Sie Ihre **n8n Production URL** ein
- Beispiel: `https://your-username.app.n8n.cloud/webhook/semaphorek-test`
- ⚠️ Stellen Sie sicher, dass keine zusätzlichen Leerzeichen am Anfang oder Ende vorhanden sind

**Trigger:**
- Wählen Sie: **"Bar Close (C)"**
- Webhook wird NUR ausgelöst, wenn der Balken schließt (nicht bei jedem Tick)
- Reduziert das Nachrichtenvolumen, konzentriert sich auf abgeschlossene Signale

**Klicken Sie auf OK**, um die Einstellungen zu speichern

---

## ⏳ Schritt 4: Webhook-Empfang testen

### n8n Listening aktivieren
1. Kehren Sie zum n8n-Workflow zurück
2. Klicken Sie auf den Webhook-Node
3. Klicken Sie auf die Schaltfläche **"Listen for Test Event"** (falls verfügbar)
4. Der Node-Status zeigt: "Waiting for webhook call..."

### Test-Nachricht von ATAS auslösen
**Option A: Auf Balken-Schließung warten**
- Lassen Sie Ihr Chart normal laufen
- Warten Sie, bis der aktuelle Balken schließt
- Webhook wird automatisch ausgelöst

**Option B: Schnelltest erzwingen (Schneller)**
- Ändern Sie den Chart-Timeframe auf **1 Minute**
- Warten Sie 1 Minute, bis der Balken schließt
- Schneller als auf 15m oder 1h Timeframe zu warten

### Empfang überprüfen
Wenn der Webhook eintrifft:
- ✅ n8n Webhook-Node zeigt **grünes Häkchen**
- ✅ Node-Panel zeigt empfangene Daten an
- ✅ Zeitstempel in n8n entspricht ATAS Balken-Schließungszeit

---

## 🔍 Schritt 5: Empfangene Daten überprüfen

### Webhook-Daten anzeigen
Klicken Sie auf den Webhook-Node, um das **Output-Panel** zu sehen:

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

### Datenstruktur verstehen
**Wichtiges Feld: `body`** - Enthält die vollständige Webhook-Nachricht

**Nachrichtenformat:**
```
DATUM UHRZEIT INSTRUMENT TIMEFRAME LIGHTS STATUS CONDITIONS BARNUMBER OPEN HIGH LOW CLOSE VPOC
```

**Ihr Beispiel könnte so aussehen:**
```
15/10/2025 14:23:45.123 ES 5m 7 C 111111100 12345 5432.00 5433.50 5431.75 5432.50 5432.25
```

Dies sind **Rohdaten** - wir werden sie in den nächsten Lektionen analysieren

---

## ✅ Erfolgs-Checkliste

Überprüfen Sie, ob alles funktioniert, bevor Sie fortfahren:

- [ ] Webhook-Node in n8n erstellt
- [ ] Production URL kopiert
- [ ] ATAS-Indikator mit Webhook-URL konfiguriert
- [ ] "Enable Webhook" Kontrollkästchen AN
- [ ] Test-Nachricht in n8n empfangen
- [ ] Webhook-Daten im Node-Output-Panel sichtbar
- [ ] Nachrichtenformat sieht korrekt aus (Datum, Instrument, Preise sichtbar)

**Alles abgehakt?** Herzlichen Glückwunsch! Ihr erster Webhook-Empfänger funktioniert!

---

## 🎓 Was Sie gelernt haben

✅ Webhook-Trigger-Node in n8n erstellt
✅ ATAS-Indikator zum Senden von Webhooks konfiguriert
✅ Webhook-Daten empfangen und angezeigt
✅ Grundlegende Webhook-Datenstruktur verstanden

---

## 🚀 Nächste Schritte

**Sie können Webhooks empfangen!** Jetzt lassen Sie uns ETWAS damit machen:

### Unmittelbare nächste Schritte
- [Webhooks testen](03-Webhooks-testen.md) - Überprüfen Sie mit webhook.site, beheben Sie Probleme
- [semaPHorek Webhook-Format](../Webhook-Referenz/semaPHorek-Webhook-Format.md) - Nachrichtenstruktur im Detail verstehen

### Video-Tutorials (Discord #video-tutorials)
- **Video 2:** "Your First Telegram Alert" - Webhook-Daten an Telegram senden
- **Video 3:** "Multi-Indicator Confluence" - Mehrere Indikator-Webhooks kombinieren

### Bauen Sie Ihre Fähigkeiten aus
- Fügen Sie weitere Indikatoren hinzu (Linescope, NODEtective)
- Erstellen Sie mehrere Webhook-Empfänger
- Beginnen Sie darüber nachzudenken, was SIE automatisieren möchten

---

## 🛠️ Fehlerbehebung

### Webhook-Node zeigt keine Daten
**Problem:** ATAS-Indikator sendet nicht, oder falsche URL

**Lösungen:**
1. Überprüfen Sie, ob "Enable Webhook" in ATAS aktiviert ist
2. Bestätigen Sie, dass die URL korrekt kopiert wurde (keine Leerzeichen)
3. Versuchen Sie die [Test-Anleitung](03-Webhooks-testen.md) zuerst mit webhook.site
4. Überprüfen Sie, ob die Windows-Firewall ATAS nicht blockiert

### Nachricht empfangen, aber leer
**Problem:** Indikator hat noch nicht berechnet, oder falsche Konfiguration

**Lösungen:**
1. Warten Sie, bis das Chart vollständig geladen ist (mehrere Balken an Daten erforderlich)
2. Bestätigen Sie, dass der Indikator im Chart sichtbar ist (nicht versteckt)
3. Überprüfen Sie, ob die Indikator-Einstellungen gespeichert sind (OK klicken)
4. Versuchen Sie einen anderen Balken-Abschluss (warten Sie auf den nächsten Balken)

### URL zu lang oder bricht ab
**Problem:** URL-Formatierungsproblem in ATAS-Einstellungen

**Lösungen:**
1. Fügen Sie nicht manuell `http://` oder `https://` hinzu (n8n liefert vollständige URL)
2. Kopieren Sie die gesamte URL von n8n (einschließlich https://)
3. Fügen Sie keine zusätzlichen Schrägstriche am Ende hinzu
4. Wenn die URL abgeschnitten ist, verwenden Sie einen kürzeren Pfadnamen im Webhook-Node

### Mehrere Nachrichten auf einmal
**Problem:** Echtzeit-Updates aktiviert statt nur Balken-Schließung

**Lösungen:**
1. Ändern Sie den ATAS-Trigger von "Real-time (O)" auf "Bar Close (C)"
2. Reduziert das Nachrichtenvolumen erheblich
3. Konzentriert sich nur auf abgeschlossene Signale

---

## 💡 Profi-Tipps

### Webhook-Pfade organisieren
Verwenden Sie Namenskonventionen für mehrere Indikatoren:
```
/webhook/semaphorek-mnq-4renko
/webhook/linescope-es-5m
/webhook/nodetective-nq-15m
```

**Vorteile:**
- Erkennen Sie, welcher Indikator allein an der URL
- Einfach in n8n-Ausführungsprotokollen zu verfolgen
- Professionelle Organisation von Tag eins an

### Workflow regelmäßig speichern
n8n speichert automatisch, aber wenn Sie große Änderungen vornehmen:
1. Klicken Sie explizit auf die **"Save"** Schaltfläche
2. Oder drücken Sie **Strg+S** (Windows) / **Cmd+S** (Mac)
3. Suchen Sie nach grünem Häkchen zur Bestätigung der Speicherung

### Für Experimente duplizieren
Bevor Sie einen funktionierenden Workflow ändern:
1. Rechtsklick auf Workflow in der Liste
2. Wählen Sie **"Duplicate"**
3. Umbenennen in `semaPHorek - First Test (BACKUP)`
4. Experimentieren Sie sicher, ohne die funktionierende Version zu zerstören

### Test URL vs. Production URL
**Test URL:**
- Temporär (verschwindet nach Ausführung)
- Gut für erste Tests
- Konfigurieren Sie ATAS nicht mit dieser

**Production URL:**
- Permanent (bleibt aktiv)
- Verwenden Sie diese für ATAS-Indikator-Einstellungen
- Kann 24/7 Webhooks empfangen

---

## 📚 Verwandte Dokumentation

- [n8n-Konto erstellen](01-n8n-Konto-erstellen.md)
- [Webhooks testen](03-Webhooks-testen.md)
- [semaPHorek Webhook-Format](../Webhook-Referenz/semaPHorek-Webhook-Format.md)

---

## 🎬 Video-Tutorial

Schauen Sie sich **Video 1: "n8n Basics"** in Discord #video-tutorials für eine visuelle Anleitung zur Erstellung von Webhook-Nodes an.

Schauen Sie sich **Video 2: "Your First Telegram Alert"** an, um zu sehen, wie Sie diese Webhook-Daten VERWENDEN (Benachrichtigungen senden, in Datenbank protokollieren usw.)

---

*Zuletzt aktualisiert: 15. Oktober 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
*5D Lab - Systematic Trading Intelligence*
