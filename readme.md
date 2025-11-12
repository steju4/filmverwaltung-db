# Projektarbeit Datenbank: Filmverwaltung

Dieses Repository enthält das `main.sql`-Skript für die Projektarbeit im Modul Datenbanken. Das Skript erstellt eine MariaDB-Datenbank zur Verwaltung einer privaten Filmsammlung, inklusive eines detaillierten Berechtigungskonzepts.

## ⚙️ Voraussetzungen

* Eine laufende MariaDB-Datenbankinstanz.
* Zugriff auf einen Admin-Benutzer (z.B. `root`), der die Berechtigung hat, Datenbanken zu löschen (`DROP DATABASE`) und Benutzer/Rollen zu erstellen (`CREATE USER`, `CREATE ROLE`).

## 🚀 Installationsanleitung

Die Installation erfolgt in zwei Schritten. **Empfehlenswerter Ablauf:**

1.  Terminal öffnen und in den Ordner mit `main.sql` und `data.sql` wechseln.
2.  MariaDB-Shell mit entsprechenden Rechten zu DB anlegen starten (z.B. `mariadb -u root -p`).
3.  Datenbank anlegen und verwenden:
    ```sql
    CREATE DATABASE IF NOT EXISTS filmverwaltung;
    USE filmverwaltung;
    ```
4.  Skripte nacheinander einbinden:
    ```sql
    SOURCE main.sql;
    SOURCE data.sql;
    ```

Alternativ lassen sich die Skripte über Umleitung ausführen:

1.  Terminal öffnen, in den Ordner mit den Skripten wechseln und anschließend:
    ```bash
    mariadb -u root -p < main.sql
    ```
2.  Danach `data.sql` gegen die frisch angelegte Datenbank ausführen:
    ```bash
    mariadb -u root -p filmverwaltung < data.sql
    ```

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
