# Webhooks testen

> **Testen Sie Webhooks IMMER VOR dem Verbinden von Live-Indikatoren**
> Überprüfen Sie, ob Ihr Setup funktioniert, zuerst mit einfachen Test-Nachrichten

---

## 🎯 Warum zuerst testen?

**Frustration vermeiden:**
- Bestätigen Sie, dass n8n Nachrichten korrekt empfängt
- Überprüfen Sie, dass ATAS Webhooks senden kann (Firewall, Netzwerk)
- Debuggen Sie Probleme, ohne auf Trading-Signale warten zu müssen
- Bauen Sie Vertrauen in Ihr Setup auf

**Testen → Überprüfen → Live gehen** (überspringen Sie niemals das Testen!)

---

## 🧪 Methode 1: webhook.site (Am einfachsten)

### Was ist webhook.site?
Kostenloses Online-Tool, das temporäre Webhook-URLs erstellt und eingehende Nachrichten in Echtzeit anzeigt. Perfekt zum Überprüfen, ob ATAS Webhooks senden kann.

### Schritt 1: Test-URL erhalten
1. Gehen Sie zu [https://webhook.site](https://webhook.site)
2. Sie sehen eine automatisch generierte **eindeutige URL**
3. **Kopieren Sie diese URL** (sieht aus wie: `https://webhook.site/abc123-def456...`)

### Schritt 2: ATAS-Indikator konfigurieren
1. Öffnen Sie die ATAS-Plattform
2. Fügen Sie den Indikator zum Chart hinzu (z.B. semaPHorek Ultra)
3. Öffnen Sie die Indikator-**Einstellungen**
4. Finden Sie den **Webhook** Bereich
5. **Enable Webhook** Kontrollkästchen: ✅ AN
6. **Webhook URL:** Fügen Sie die webhook.site URL ein
7. **Trigger:** Wählen Sie "Bar Close" (C)
8. Klicken Sie auf **OK**

### Schritt 3: Test-Signal generieren
**Option A: Auf Balken-Schließung warten**
- Lassen Sie das Chart normal laufen
- Warten Sie, bis der Balken schließt
- webhook.site sollte eingehende Nachricht anzeigen

**Option B: Signal erzwingen (Schneller)**
- Ändern Sie den Timeframe auf 1 Minute
- Warten Sie 1 Minute, bis der Balken schließt
- Sofortiger Test ohne Warten

### Schritt 4: Nachricht überprüfen
Auf webhook.site sollten Sie sehen:
```
25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75
```

**Erfolgs-Indikatoren:**
- ✅ Nachricht erscheint im webhook.site Log
- ✅ Zeitstempel entspricht aktueller Zeit
- ✅ Instrument/Timeframe entspricht Ihrem Chart
- ✅ Daten sehen vollständig aus (keine fehlenden Felder)

### Fehlerbehebung webhook.site
**Keine Nachricht empfangen?**
- Überprüfen Sie, ob "Enable Webhook" in ATAS-Einstellungen AN ist
- Überprüfen Sie, ob die URL korrekt kopiert wurde (keine zusätzlichen Leerzeichen)
- Überprüfen Sie, ob die Windows-Firewall ATAS nicht blockiert
- Versuchen Sie einen anderen Indikator/Chart (bestätigen Sie, dass ATAS überhaupt senden kann)

---

## 🧪 Methode 2: n8n Test-Webhook

### Schritt 1: Webhook-Node in n8n erstellen
1. Öffnen Sie Ihren n8n-Workflow
2. Klicken Sie auf die **"+" Schaltfläche**, um einen Node hinzuzufügen
3. Suchen Sie nach **"Webhook"**
4. Wählen Sie den **"Webhook"** Trigger-Node
5. Node erscheint auf der Arbeitsfläche

### Schritt 2: Webhook-Node konfigurieren
1. Klicken Sie auf den Webhook-Node, um die Einstellungen zu öffnen
2. **HTTP Method:** `POST` (Standard)
3. **Path:** Wählen Sie einen beschreibenden Pfad (z.B. `semaphorek-test`)
4. **Authentication:** None (zum Testen)
5. Klicken Sie auf die **"Execute Node"** Schaltfläche

### Schritt 3: Webhook-URL kopieren
n8n zeigt **Production URL** und **Test URL**:
```
Production: https://your-n8n.app/webhook/semaphorek-test
Test: https://your-n8n.app/webhook-test/semaphorek-test
```

**Verwenden Sie Test URL** für erste Tests (verschwindet nach Ausführung)

### Schritt 4: ATAS-Indikator konfigurieren
Wie bei Methode 1:
1. Öffnen Sie Indikator-Einstellungen in ATAS
2. Enable Webhook aktivieren
3. Fügen Sie **n8n Test URL** ein
4. Setzen Sie Trigger auf "Bar Close"
5. Klicken Sie auf OK

### Schritt 5: Auf Webhook-Node warten
1. n8n Webhook-Node zeigt **"Waiting for webhook call..."**
2. Lassen Sie das ATAS-Chart laufen, bis der Balken schließt
3. Wenn der Webhook eintrifft, wird der Node ausgeführt
4. **Output-Daten** erscheinen im Node-Panel

### Schritt 6: Datenstruktur überprüfen
Klicken Sie auf den Webhook-Node, um empfangene Daten zu sehen:
```json
{
  "headers": {...},
  "params": {},
  "query": {},
  "body": "25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75"
}
```

**Erfolg:** `body` Feld enthält vollständige Webhook-Nachricht

---

## 🧪 Methode 3: Manuelle Webhook-Tests (Fortgeschritten)

### cURL verwenden (Befehlszeile)
Testen Sie Ihren n8n-Webhook ohne ATAS:

```bash
curl -X POST https://your-n8n.app/webhook/semaphorek-test \
  -H "Content-Type: text/plain" \
  -d "25/09/2025 18:27:08.861 MNQ 4Renko 5 C 111111101 37748 24576.75 24577.50 24576.25 24577.50 24576.75"
```

**Wann zu verwenden:**
- Testen Sie n8n-Workflow-Logik ohne ATAS
- Überprüfen Sie, ob n8n überhaupt Webhooks empfangen kann
- Debuggen Sie Parsing-Probleme mit bekannten Daten

### Postman verwenden (GUI-Tool)
1. Laden Sie [Postman](https://www.postman.com/downloads/) herunter (kostenlos)
2. Erstellen Sie eine **New Request**
3. Setzen Sie die Methode auf **POST**
4. Geben Sie die Webhook-URL ein
5. **Body tab** → Wählen Sie "raw" → Typ "Text"
6. Fügen Sie eine Beispiel-Webhook-Nachricht ein
7. Klicken Sie auf **Send**

**Ergebnis:** n8n empfängt Test-Nachricht, Workflow wird ausgeführt

---

## ✅ Überprüfungs-Checkliste

Bevor Sie Live-Indikatoren mit n8n verbinden:

- [ ] Erfolgreich mit webhook.site getestet
- [ ] Überprüft, dass ATAS Webhooks senden kann (Firewall/Netzwerk OK)
- [ ] Webhook-Node in n8n erstellt
- [ ] Test-Nachricht erfolgreich in n8n empfangen
- [ ] Nachrichtenformat entspricht Indikator-Dokumentation
- [ ] Bestätigt, dass alle Felder vorhanden sind (Datum, Zeit, Instrument usw.)

**Alle Kontrollkästchen ✅?** Sie sind bereit, echte Workflows zu erstellen!

---

## 🎓 Nächste Schritte

**Sie haben bestätigt, dass Webhooks funktionieren!** Erstellen Sie jetzt Ihre erste Automatisierung:

- [semaPHorek Webhook-Referenz](../Webhook-Referenz/semaPHorek-Webhook-Format.md) - Webhook-Daten analysieren und verwenden
- Video 2: "Your First Telegram Alert" (Discord #video-tutorials)
- Video 3: "Multi-Indicator Confluence Basics" (Discord #video-tutorials)

---

## 🛠️ Häufige Test-Probleme

### webhook.site zeigt nichts an
**Mögliche Ursachen:**
- Webhook in ATAS-Indikator-Einstellungen deaktiviert
- URL falsch kopiert (zusätzliche Leerzeichen, falsche URL)
- Windows-Firewall blockiert ausgehende ATAS-Verbindungen
- Indikator nicht im aktiven Chart

**Lösungen:**
1. Überprüfen Sie, ob "Enable Webhook" Kontrollkästchen AN ist
2. Kopieren Sie die URL erneut sorgfältig (keine nachfolgenden Leerzeichen)
3. Überprüfen Sie Windows-Firewall-Einstellungen (ATAS.exe erlauben)
4. Bestätigen Sie, dass der Indikator im Chart sichtbar ist (nicht versteckt)

### n8n Webhook-Node wird nie ausgelöst
**Mögliche Ursachen:**
- Verwendung der Production URL anstelle der Test URL
- Webhook-Node nicht im "listening" Zustand
- ATAS sendet an falsche URL
- n8n.io Cloud-Service-Problem

**Lösungen:**
1. Klicken Sie auf die "Execute Node" Schaltfläche am Webhook-Node (startet Listening)
2. Verwenden Sie Test URL für erste Tests (einfacher zu debuggen)
3. Überprüfen Sie die exakte URL in ATAS-Einstellungen (erneut kopieren)
4. Versuchen Sie zuerst webhook.site (bestätigt, dass ATAS-Seite funktioniert)

### Nachricht empfangen, aber unvollständig
**Mögliche Ursachen:**
- Indikator berechnet noch (nicht genug Daten)
- Falsche Content-Type-Einstellung
- Nachrichten-Codierungsproblem

**Lösungen:**
1. Warten Sie, bis das Chart vollständig geladen ist (mehrere Balken an Daten)
2. Bestätigen Sie, dass der Webhook-Node `text/plain` Content-Type erwartet
3. Überprüfen Sie die Indikator-Version (stellen Sie sicher, dass die neueste Ultra-Version verwendet wird)

### Firewall blockiert Webhooks
**Symptome:**
- webhook.site zeigt nichts an
- ATAS zeigt keine Fehler an
- Andere Internet-Funktionen funktionieren einwandfrei

**Lösungen:**
1. **Windows Defender Firewall:**
   - Öffnen Sie Windows-Sicherheit
   - Firewall & Netzwerkschutz
   - App durch Firewall zulassen
   - Finden Sie ATAS.exe
   - Aktivieren Sie für private und öffentliche Netzwerke

2. **Drittanbieter-Firewall:**
   - Überprüfen Sie Firewall-Logs auf blockierte ATAS-Verbindungen
   - Fügen Sie ATAS.exe zu erlaubten Anwendungen hinzu
   - Erlauben Sie ausgehendes HTTPS (Port 443)

---

## 💡 Best Practices beim Testen

### Immer zuerst auf niedrigem Timeframe testen
- Verwenden Sie 1-Minuten-Chart zum Testen (schnelle Balken-Schließungen)
- Warten Sie nicht 1 Stunde zum Testen auf 1h Timeframe
- Wechseln Sie nach Bestätigung zurück zum Trading-Timeframe

### Jeden Indikator separat testen
- Konfigurieren Sie nicht 5 Indikatoren auf einmal
- Testen Sie einen, überprüfen Sie, ob er funktioniert, fügen Sie dann den nächsten hinzu
- Einfacher zu debuggen, wenn etwas kaputt geht

### webhook.site Tab offen halten
- Während des ersten Setups, halten Sie webhook.site zur Überwachung offen
- Auch nachdem n8n funktioniert, verwenden Sie es, um zu überprüfen, ob ATAS noch sendet
- Schnelle Überprüfung, wenn der Workflow später nicht mehr funktioniert

### Webhook-URLs dokumentieren
Führen Sie eine Liste in Notepad/Obsidian:
```
semaPHorek MNQ 4Renko: https://your-n8n.app/webhook/semaphorek-mnq
Linescope ES 5m: https://your-n8n.app/webhook/linescope-es
NODEtective NQ 15m: https://your-n8n.app/webhook/nodetective-nq
```

**Warum?** Einfach neu zu konfigurieren, wenn Einstellungen zurückgesetzt werden

---

## 📚 Verwandte Dokumentation

- [n8n-Konto erstellen](01-n8n-Konto-erstellen.md)
- [Ihr erster Webhook-Empfänger](02-Ihr-erster-Webhook.md)
- [semaPHorek Webhook-Format](../Webhook-Referenz/semaPHorek-Webhook-Format.md)

---

*Zuletzt aktualisiert: 15. Oktober 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
*5D Lab - Systematic Trading Intelligence*
