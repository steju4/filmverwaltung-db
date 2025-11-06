# Projektarbeit Datenbank: Filmverwaltung

Dieses Repository enthält das `main.sql`-Skript für die Projektarbeit im Modul Datenbanken. Das Skript erstellt eine MariaDB-Datenbank zur Verwaltung einer privaten Filmsammlung, inklusive eines detaillierten Berechtigungskonzepts.

## 📦 Inhalt der `main.sql` Datei

Das Skript ist in zwei Hauptabschnitte unterteilt:

1.  **Abschnitt 1: Grundlegendes Datenbankschema**
    * Erstellt die Datenbank `filmverwaltung` (nachdem eine eventuell vorhandene Version gelöscht wurde).
    * Erstellt alle 9 Kerntabellen (`Filme`, `Personen`, `Benutzer`, `Rollen`, `Watchlist` etc.) mit den notwendigen Primärschlüsseln, Fremdschlüsseln, `UNIQUE`-Constraints und `CHECK`-Constraints.

2.  **Abschnitt 2: Kernsystem und Berechtigungen**
    * Befüllt die Anwendungstabellen `Rollen` und `Benutzer` mit den Stammdaten für die Logik.
    * Erstellt die MariaDB-Systemrollen (`rolle_admin`, `rolle_mitglied`, `rolle_gast`).
    * Erstellt die MariaDB-Systembenutzer (z.B. 'julian', 'max', 'sophie') mit Passwörtern.
    * Erstellt die beiden Sicherheits-`VIEW`s (`MeineWatchlist`, `MeineGesehenenFilme`), die als "Brücke" zwischen den Systembenutzern und der Anwendungslogik dienen.
    * Vergibt detaillierte `GRANT`-Berechtigungen an die Rollen.
    * Weist den Benutzern ihre jeweiligen Rollen zu und setzt diese als `DEFAULT ROLE`, damit sie beim Login automatisch aktiv sind.

## ⚙️ Voraussetzungen

* Eine laufende MariaDB-Datenbankinstanz.
* Zugriff auf einen Admin-Benutzer (z.B. `root`), der die Berechtigung hat, Datenbanken zu löschen (`DROP DATABASE`) und Benutzer/Rollen zu erstellen (`CREATE USER`, `CREATE ROLE`).

## 🚀 Installationsanleitung

Die Installation erfolgt in zwei Schritten:

### 1. Ausführen des `main.sql` Skripts

Dieses Skript erstellt die gesamte Struktur und das Sicherheitssystem.

1.  Speichern Sie die `main.sql`-Datei auf Ihrem Rechner.
2.  Öffnen Sie ein Terminal (Kommandozeile).
3.  Navigieren Sie in das Verzeichnis, in dem die `main.sql` liegt.
4.  Führen Sie das Skript mit `root`-Rechten aus (Sie werden nach Ihrem `root`-Passwort gefragt):

    ```bash
    mariadb -u root -p < main.sql
    ```

### 2. Datenbefüllung

Nach der Ausführung von `main.sql` ist die Datenbank strukturell fertig, aber noch **leer** (bis auf die 6 Benutzer und 3 Rollen). Um die Datenbank zu nutzen, muss ein separates Skript für die Datenbefüllung (Phase 3) ausgeführt werden.

1.  Führen Sie das Skript `data.sql` ebenfalls als `root` aus (z.B. `mariadb -u root -p < data.sql`).

## 👨‍💻 Verwendung nach der Erstellung

Nachdem die Skripte ausgeführt wurde, kann die Datenbank getestet werden, indem man sich als einer der definierten Benutzer anmeldet.

### Testbenutzer & Rollen

Alle Benutzer haben das Passwort **`'password'`**.

| Benutzername | Anwendungs-Rolle | MariaDB-Rolle | Zweck |
| :--- | :--- | :--- | :--- |
| `julian` | Administrator | `rolle_admin` | Vollzugriff, kann alles. |
| `lucius` | Administrator | `rolle_admin` | Vollzugriff, kann alles. |
| `atussa` | Administrator | `rolle_admin` | Vollzugriff, kann alles. |
| `max` | Mitglied | `rolle_mitglied` | Lesen, Hinzufügen, Ändern (kein Löschen). Nur Zugriff auf eigene Listen. |
| `lena` | Mitglied | `rolle_mitglied` | Lesen, Hinzufügen, Ändern (kein Löschen). Nur Zugriff auf eigene Listen. |
| `sophie` | Gast | `rolle_gast` | Nur Lesezugriff auf öffentliche Filmdaten. Kein Zugriff auf persönliche Listen. |
