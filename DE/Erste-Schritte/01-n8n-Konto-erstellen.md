# Dein n8n.io-Konto erstellen

> **Monat 1 ist KOSTENLOS** - Voller n8n.io-Cloud-Zugang ohne Kreditkarte erforderlich

---

## 🎯 Warum n8n?

**Europäisches Unternehmen, Berlin-basiert** - Datensouveränität und Vertrauen
**Self-Hosting-Option** - Besitze deine Automatisierungsinfrastruktur
**Visueller Workflow-Builder** - Keine Programmierung erforderlich (aber Code ist verfügbar, wenn du ihn brauchst)
**ATAS-Webhook-bereit** - Perfekt für Trading-Automatisierung

---

## 📝 Schritt 1: Registrieren (KOSTENLOS - Monat 1)

### n8n.io besuchen
1. Gehe zu [https://n8n.io](https://n8n.io)
2. Klicke auf **"Get Started for Free"**
3. Wähle **"Sign up with email"**

### Konto erstellen
- **E-Mail:** Deine E-Mail-Adresse
- **Passwort:** Starkes Passwort (im Passwort-Manager speichern)
- **Name:** Dein Name oder Trading-Alias

**Keine Kreditkarte für Monat 1 Testversion erforderlich**

---

## ⚙️ Schritt 2: Deinen Plan wählen

### Kostenlose Stufe (Monat 1)
**Was du bekommst:**
- Vollständiger Workflow-Builder-Zugang
- Bis zu 5 aktive Workflows
- 2.500 Workflow-Ausführungen pro Monat
- Cloud-Hosting (keine Einrichtung erforderlich)
- Perfekt zum Lernen der 5D Lab Grundlagen

**Einschränkungen:**
- Maximum 5 Workflows
- 2.500 Ausführungen/Monat (ca. 83 pro Tag)
- Nur Cloud (kein Self-Hosting)

**Reicht das?**
✅ JA für Monat 1-2 (Grundlagen lernen)
⚠️ Möglicherweise Upgrade ab Monat 3+ erforderlich (mehrere Indikatoren, hochfrequente Signale)

### Bezahlte Pläne (Monat 2+)
Wenn du bereit bist zu skalieren:

**Starter Plan (~$20/Monat):**
- 20 aktive Workflows
- 10.000 Ausführungen/Monat
- Weiterhin Cloud-gehostet

**Pro Plan (~$50/Monat):**
- Unbegrenzte Workflows
- 50.000+ Ausführungen/Monat
- Priority Support

**Self-Hosted (KOSTENLOS, aber erfordert VPS):**
- Unbegrenzt alles
- Volle Kontrolle
- Erfordert technische Einrichtung (Monat 4+ Inhalt)

---

## 🖥️ Schritt 3: Erster Login

### Initiale Einrichtung
1. **E-Mail bestätigen** (Posteingang auf Verifizierung prüfen)
2. **Einloggen** ins n8n.io Dashboard
3. **Willkommens-Tutorial** erscheint (optional - du kannst es überspringen)

### Dashboard-Übersicht
**Hauptbereiche:**
- **Workflows** - Deine Automatisierungsliste (momentan leer)
- **Executions** - Workflow-Ausführungshistorie
- **Credentials** - Gespeicherte API-Schlüssel (für später)
- **Settings** - Kontokonfiguration

---

## 🚀 Schritt 4: Deinen ersten Workflow erstellen

### Neuen Workflow starten
1. Klicke auf **"New Workflow"** Button (oben rechts)
2. Du siehst eine leere Leinwand mit **"+"** Button

### Workflow-Canvas Grundlagen
- **Nodes** - Einzelne Schritte in deiner Automatisierung
- **Connections** - Linien zwischen Nodes zeigen Datenfluss
- **Trigger Node** - Wie Workflow startet (Webhook, Zeitplan, manuell)
- **Action Nodes** - Was Workflow tut (Telegram senden, Google Sheets schreiben, etc.)

---

## 📌 Schritt 5: Deinen Workflow speichern

### Namenskonvention
Verwende klare, beschreibende Namen:
- ✅ `semaPHorek → Telegram Benachrichtigungen`
- ✅ `MNQ Signal Datenbank`
- ❌ `Workflow 1`
- ❌ `Test`

**Warum?** Du wirst bald mehrere Workflows haben. Klare Namen = einfaches Management.

### Workflow speichern
1. Klicke auf Workflow-Namen oben (Standard: "My workflow")
2. Umbenennen in beschreibenden Namen
3. Enter drücken
4. Workflow speichert automatisch (grünes Häkchen erscheint)

---

## ✅ Verifizierungs-Checkliste

Bevor du zum nächsten Leitfaden fortfährst:

- [ ] n8n.io-Konto erstellt
- [ ] E-Mail verifiziert (Posteingang prüfen)
- [ ] Erfolgreich ins Dashboard eingeloggt
- [ ] Ersten leeren Workflow erstellt
- [ ] Workflow mit beschreibendem Namen umbenannt
- [ ] Workflow gespeichert (grünes Häkchen sichtbar)

---

## 🎓 Nächste Schritte

**Du bist bereit!** Fahre fort mit:
- [Dein erster Webhook-Empfänger](02-Ihr-erster-Webhook.md) - Webhook-Node erstellen zum Empfang von ATAS-Signalen
- [Webhooks testen](03-Webhooks-testen.md) - Alles überprüfen funktioniert vor Live-Betrieb

---

## 🛠️ Fehlerbehebung

### E-Mail-Verifizierung nicht erhalten
- Spam-Ordner prüfen
- 5 Minuten warten (kann verzögert sein)
- Neue Verifizierungs-E-Mail von Login-Seite anfordern

### Kann nicht auf Dashboard zugreifen
- Browser-Cache und Cookies löschen
- Inkognito/Private-Browsing-Modus versuchen
- Anderen Browser versuchen (Chrome, Firefox, Edge)

### Workflow speichert nicht
- Internetverbindung prüfen
- Seite aktualisieren und erneut versuchen
- Wenn persistent, n8n Support kontaktieren

---

## 💡 Tipps für Erfolg

### Früh organisieren
Beim Erstellen von Workflows, mit klarer Benennung organisieren:
- Präfix nach Indikator: `semaPHorek -`, `Linescope -`
- Suffix nach Funktion: `- Telegram`, `- Datenbank`, `- Analyse`

**Beispiel:**
```
semaPHorek - Telegram Benachrichtigungen
semaPHorek - Signal Datenbank
Linescope - Level Breaks
NODEtective - HVN Benachrichtigungen
```

### Workflows für Tests duplizieren
Bevor du funktionierenden Workflow änderst:
1. Rechtsklick auf Workflow in Liste
2. "Duplicate" wählen
3. Umbenennen zu `[NAME] - TEST`
4. Änderungen sicher testen ohne Produktion zu brechen

### Workflow-Notizen verwenden
Notizen zu komplexen Workflows hinzufügen:
1. Auf Workflow-Namen klicken
2. Beschreibung hinzufügen, was er tut
3. Zukünftiges Du wird gegenwärtigem Du danken

---

## 📚 Verwandte Dokumentation

- [Dein erster Webhook-Empfänger](02-Ihr-erster-Webhook.md)
- [Webhooks testen](03-Webhooks-testen.md)

---

## 🎬 Video-Tutorial

Schaue Video 1: "n8n Basics - Dein Konto erstellen" im Discord #video-anleitungen Kanal für visuellen Durchgang dieses Leitfadens.

---

*Zuletzt aktualisiert: 15. Oktober 2025*
*Pavel Horák - ATAS Platform Expert & Official Partner*
*5D Lab - Systematische Trading-Intelligenz*
