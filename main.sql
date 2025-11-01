-- ====================================================================
-- SQL Skript: Erstellung der Datenbank "filmverwaltung"
-- ====================================================================

DROP DATABASE IF EXISTS filmverwaltung;
CREATE DATABASE filmverwaltung;
USE filmverwaltung;


-- ====================================================================
-- 1. Abschnitt: Grundlegendes Datenbankschema
-- ====================================================================

-- Definiert die Benutzer-Rollen (z.B. Admin, Mitglied)
CREATE TABLE Rollen (
    rollenID INT PRIMARY KEY AUTO_INCREMENT,
    rollenName VARCHAR(50) NOT NULL UNIQUE
);

-- Speichert alle Personen (Schauspieler & Regisseure)
CREATE TABLE Personen (
    personID INT PRIMARY KEY AUTO_INCREMENT,
    vorname VARCHAR(100),
    name VARCHAR(100) NOT NULL
);

-- Speichert übergeordnete Filmreihen (z.B. 'Star Wars')
CREATE TABLE Filmreihen (
    filmreiheID INT PRIMARY KEY AUTO_INCREMENT,
    reihenName VARCHAR(150) NOT NULL UNIQUE
);

-- Speichert die Filmgenres
CREATE TABLE Genres (
    genreID INT PRIMARY KEY AUTO_INCREMENT,
    genreName VARCHAR(50) NOT NULL UNIQUE
);

-- Speichert die Benutzerkonten der Anwendung
CREATE TABLE Benutzer (
    benutzerID INT PRIMARY KEY AUTO_INCREMENT,
    benutzerName VARCHAR(100) NOT NULL UNIQUE,
    rollenID INT NOT NULL,
    FOREIGN KEY (rollenID) REFERENCES Rollen(rollenID)
);

-- Zentrale Tabelle, die alle Filme der Sammlung speichert
CREATE TABLE Filme (
    filmID INT PRIMARY KEY AUTO_INCREMENT,
    titel VARCHAR(255) NOT NULL,
    erscheinungsjahr INT,
    medium VARCHAR(50),
    genreID INT NOT NULL, 
    filmreiheID INT, -- Kann NULL sein, da nicht jeder Film Teil einer Reihe ist
    FOREIGN KEY (genreID) REFERENCES Genres(genreID),
    FOREIGN KEY (filmreiheID) REFERENCES Filmreihen(filmreiheID)
);

-- Verknüpft Filme mit Personen und definiert deren Rolle (Regisseur/Schauspieler)
CREATE TABLE Film_Beteiligungen (
    filmID INT NOT NULL,
    personID INT NOT NULL,
    istRegisseur BOOLEAN NOT NULL DEFAULT FALSE,
    istSchauspieler BOOLEAN NOT NULL DEFAULT FALSE,

    -- PK stellt sicher, dass eine Person pro Film nur einen Eintrag hat
    PRIMARY KEY (filmID, personID),
    
    FOREIGN KEY (filmID) REFERENCES Filme(filmID),
    FOREIGN KEY (personID) REFERENCES Personen(personID),
    
    -- Mindestens eine Rolle muss zugewiesen sein bei Verknüpfung
    CONSTRAINT chk_mindestens_eine_rolle CHECK (istRegisseur = TRUE OR istSchauspieler = TRUE)
);

-- Verknüpft Benutzer mit Filmen auf ihrer Wunschliste
CREATE TABLE Watchlist (
    benutzerID INT NOT NULL,
    filmID INT NOT NULL,
    hinzugefuegtAm DATE DEFAULT (CURRENT_DATE),

    -- PK verhindert, dass ein Benutzer einen Film doppelt hinzufügt
    PRIMARY KEY (benutzerID, filmID),

    FOREIGN KEY (benutzerID) REFERENCES Benutzer(benutzerID),
    FOREIGN KEY (filmID) REFERENCES Filme(filmID)
);

-- Verknüpft Benutzer mit Filmen, die sie gesehen und bewertet haben
CREATE TABLE GeseheneFilme (
    benutzerID INT NOT NULL,
    filmID INT NOT NULL,
    gesehenAm DATE,
    persoenlicheBewertung INT,

    -- PK stellt sicher, dass ein Benutzer einen Film nur einmal bewertet
    PRIMARY KEY (benutzerID, filmID),
    
    FOREIGN KEY (benutzerID) REFERENCES Benutzer(benutzerID),
    FOREIGN KEY (filmID) REFERENCES Filme(filmID),

    -- Stellt sicher, dass die Bewertung im Bereich 1-10 liegt
    CONSTRAINT chk_bewertung CHECK (persoenlicheBewertung >= 1 AND persoenlicheBewertung <= 10)
);


-- ====================================================================
-- 2. Abschnitt: Kernsystem und Berechtigungen
-- ====================================================================

-- --- Anwendungstabelle für Rollen (Tabelle "Rollen") befüllen ---
INSERT INTO Rollen (rollenName) VALUES ('Administrator'); 
INSERT INTO Rollen (rollenName) VALUES ('Mitglied');
INSERT INTO Rollen (rollenName) VALUES ('Gast');

-- --- MariaDB Systemrollen erstellen ---
CREATE ROLE 'rolle_admin', 'rolle_mitglied', 'rolle_gast';

-- --- Anwendungstabelle für Nutzer (Tabelle "Benutzer") befüllen ---
INSERT INTO Benutzer (benutzerName, rollenID) 
VALUES ('julian', 1); --Administrator
INSERT INTO Benutzer (benutzerName, rollenID) 
VALUES ('lucius', 1); --Administrator
INSERT INTO Benutzer (benutzerName, rollenID)
VALUES ('atussa', 1); --Administrator
INSERT INTO Benutzer (benutzerName, rollenID)
VALUES ('max', 2); --Mitglied
INSERT INTO Benutzer (benutzerName, rollenID)
VALUES ('lena', 2); --Mitglied
INSERT INTO Benutzer (benutzerName, rollenID)
VALUES ('sophie', 3); --Gast

-- --- MariaDB Systembenutzer erstellen ---
CREATE USER 'julian'@'localhost';
CREATE USER 'lucius'@'localhost';
CREATE USER 'atussa'@'localhost';
CREATE USER 'max'@'localhost';
CREATE USER 'lena'@'localhost';
CREATE USER 'sophie'@'localhost';


-- --- VIEW: "MeineWatchlist" als persönlicher Filter für die Watchlist Tabelle ---

-- Der View dient als "Brücke" zwischen dem MariaDB-Systembenutzer (z.B. 'julian@localhost') und der Anwendungstabelle 'Benutzer'.
CREATE VIEW MeineWatchlist AS
SELECT 
    benutzerID, 
    filmID, 
    hinzugefuegtAm
FROM 
    Watchlist
WHERE
    -- Dynamischer Filter:
    -- 1. CURRENT_USER holt den aktuell eingeloggten MariaDB-Benutzer (z.B. 'julian@localhost')
    -- 2. SUBSTRING_INDEX extrahiert den reinen Namen (z.B. 'julian')
    -- 3. Subquery sucht die 'benutzerID' (z.B. 1) aus unserer 'Benutzer'-Tabelle dazu
    -- --> Der View zeigt nur Zeilen an, die zur 'benutzerID' des eingeloggten Benutzers passen
    benutzerID = (SELECT benutzerID FROM Benutzer WHERE benutzerName = SUBSTRING_INDEX(CURRENT_USER(), '@', 1))

-- WITH CHECK OPTION: Sichert inserts/updates ab. Verhindert dass 'lucius' (ID 2) einen Eintrag mit der 'benutzerID' von 'julian' (ID 1) erstellen kann.
WITH CHECK OPTION;


-- --- VIEW: "MeineGesehenenFilme" als persönlicher Filter für die GeseheneFilme Tabelle ---
CREATE VIEW MeineGesehenenFilme AS
SELECT 
    benutzerID, 
    filmID, 
    gesehenAm, 
    persoenlicheBewertung
FROM 
    GeseheneFilme
WHERE
    -- -> Gleiches Prinzip, wie oben: Filtert dynamisch auf die 'benutzerID' des eingeloggten Benutzers.
    benutzerID = (SELECT benutzerID FROM Benutzer WHERE benutzerName = SUBSTRING_INDEX(CURRENT_USER(), '@', 1))
WITH CHECK OPTION;


-- --- Rechte an die MariaDB Systemrollen vergeben ---

-- Rechte für 'rolle_gast' (Nur Lesezugriff) --
-- Der Gast darf die öffentlichen Sammlungs-Tabellen sehen.
GRANT SELECT ON filmverwaltung.Filme TO 'rolle_gast';
GRANT SELECT ON filmverwaltung.Personen TO 'rolle_gast';
GRANT SELECT ON filmverwaltung.Filmreihen TO 'rolle_gast';
GRANT SELECT ON filmverwaltung.Genres TO 'rolle_gast';
GRANT SELECT ON filmverwaltung.Film_Beteiligungen TO 'rolle_gast';
-- Der Gast bekommt keinen Zugriff auf 'Watchlist' oder 'GeseheneFilme'

-- Rechte für 'rolle_mitglied' (Lesen + Hinzufügen/Bearbeiten) --
-- Ein Mitglied erbt erstmal alle Rechte vom Gast.
GRANT 'rolle_gast' TO 'rolle_mitglied';

-- Mitglieder dürfen Filme, Personen,... hinzufügen und bearbeiten, aber nicht löschen.
GRANT INSERT, UPDATE ON filmverwaltung.Filme TO 'rolle_mitglied';
GRANT INSERT, UPDATE ON filmverwaltung.Personen TO 'rolle_mitglied';
GRANT INSERT, UPDATE ON filmverwaltung.Filmreihen TO 'rolle_mitglied';
GRANT INSERT, UPDATE ON filmverwaltung.Genres TO 'rolle_mitglied';
GRANT INSERT, UPDATE ON filmverwaltung.Film_Beteiligungen TO 'rolle_mitglied';

-- Mitglieder verwalten ihre persönlichen Listen nur über die Views.
GRANT SELECT, INSERT, UPDATE, DELETE ON filmverwaltung.MeineWatchlist TO 'rolle_mitglied';
GRANT SELECT, INSERT, UPDATE, DELETE ON filmverwaltung.MeineGesehenenFilme TO 'rolle_mitglied';

-- Rechte für 'rolle_admin' (Vollzugriff) --
-- Ein Admin darf alles, inklusive löschen und die Struktur ändern.
GRANT ALL PRIVILEGES ON filmverwaltung.* TO 'rolle_admin';


-- --- Zuweisung der MariaDB Systemrollen an die Benutzer ---
GRANT 'rolle_admin' TO 'julian'@'localhost';
GRANT 'rolle_admin' TO 'lucius'@'localhost';
GRANT 'rolle_admin' TO 'atussa'@'localhost';
GRANT 'rolle_mitglied' TO 'max'@'localhost';
GRANT 'rolle_mitglied' TO 'lena'@'localhost';
GRANT 'rolle_gast' TO 'sophie'@'localhost';