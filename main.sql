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
    benutzerName VARCHAR(100) NOT NULL UNIQUE, -- Benutzername muss eindeutig sein für Login
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
CREATE ROLE IF NOT EXISTS 'rolle_admin', 'rolle_mitglied', 'rolle_gast';

-- --- Anwendungstabelle für Nutzer (Tabelle "Benutzer") befüllen ---
INSERT INTO Benutzer (benutzerName, rollenID) 
VALUES ('julian', 1); -- Administrator
INSERT INTO Benutzer (benutzerName, rollenID) 
VALUES ('lucius', 1); -- Administrator
INSERT INTO Benutzer (benutzerName, rollenID)
VALUES ('atussa', 1); -- Administrator
INSERT INTO Benutzer (benutzerName, rollenID)
VALUES ('max', 2); -- Mitglied
INSERT INTO Benutzer (benutzerName, rollenID)
VALUES ('lena', 2); -- Mitglied
INSERT INTO Benutzer (benutzerName, rollenID)
VALUES ('sophie', 3); -- Gast

-- --- MariaDB Systembenutzer erstellen ---
CREATE USER IF NOT EXISTS 'julian'@'localhost' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'lucius'@'localhost' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'atussa'@'localhost' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'max'@'localhost' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'lena'@'localhost' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'sophie'@'localhost' IDENTIFIED BY 'password';

-- Passwörter der MariaDB Systembenutzer setzen (falls User schon existierte)
ALTER USER 'julian'@'localhost' IDENTIFIED BY 'password';
ALTER USER 'lucius'@'localhost' IDENTIFIED BY 'password';
ALTER USER 'atussa'@'localhost' IDENTIFIED BY 'password';
ALTER USER 'max'@'localhost' IDENTIFIED BY 'password';
ALTER USER 'lena'@'localhost' IDENTIFIED BY 'password';
ALTER USER 'sophie'@'localhost' IDENTIFIED BY 'password';


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
    -- 1. USER holt den aktuell eingeloggten MariaDB-Benutzer (z.B. 'julian@localhost')
    -- 2. SUBSTRING_INDEX extrahiert den reinen Namen (z.B. 'julian')
    -- 3. Subquery sucht die 'benutzerID' (z.B. 1) aus der 'Benutzer'-Tabelle dazu
    -- --> Der View zeigt nur Zeilen an, die zur 'benutzerID' des eingeloggten Benutzers passen
    benutzerID = (SELECT benutzerID FROM Benutzer WHERE benutzerName = SUBSTRING_INDEX(USER(), '@', 1))

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
    benutzerID = (SELECT benutzerID FROM Benutzer WHERE benutzerName = SUBSTRING_INDEX(USER(), '@', 1))
WITH CHECK OPTION;


-- --- Rechte an die MariaDB Systemrollen vergeben ---

-- Rechte für 'rolle_gast' (Nur Lesezugriff) --
-- Der Gast darf die öffentlichen Sammlungs-Tabellen sehen
GRANT USAGE ON filmverwaltung.* TO 'rolle_gast';
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
GRANT INSERT, UPDATE ON filmverwaltung.Film_Beteiligungen TO 'rolle_mitglied';
GRANT SELECT ON filmverwaltung.Benutzer TO 'rolle_mitglied'; -- Mitglieder dürfen Benutzerinformationen einsehen (notwendig für Views)

-- Mitglieder verwalten ihre persönlichen Listen nur über die Views.
GRANT SELECT, INSERT, UPDATE, DELETE ON filmverwaltung.MeineWatchlist TO 'rolle_mitglied';
GRANT SELECT, INSERT, UPDATE, DELETE ON filmverwaltung.MeineGesehenenFilme TO 'rolle_mitglied';

-- Rechte für 'rolle_admin' (Vollzugriff) --
-- Ein Admin darf alles, inklusive löschen und die Struktur ändern.
GRANT ALL PRIVILEGES ON filmverwaltung.* TO 'rolle_admin';


-- --- Rechte der jeweiligen der MariaDB Systemrollen an die Benutzer zuweisen ---
GRANT 'rolle_gast' TO 'sophie'@'localhost';
GRANT 'rolle_mitglied' TO 'max'@'localhost';
GRANT 'rolle_mitglied' TO 'lena'@'localhost';
GRANT 'rolle_admin' TO 'julian'@'localhost';
GRANT 'rolle_admin' TO 'lucius'@'localhost';
GRANT 'rolle_admin' TO 'atussa'@'localhost';

-- Standardrolle setzen
SET DEFAULT ROLE 'rolle_gast' FOR 'sophie'@'localhost';
SET DEFAULT ROLE 'rolle_mitglied' FOR 'max'@'localhost';
SET DEFAULT ROLE 'rolle_mitglied' FOR 'lena'@'localhost';
SET DEFAULT ROLE 'rolle_admin' FOR 'julian'@'localhost';
SET DEFAULT ROLE 'rolle_admin' FOR 'lucius'@'localhost';
SET DEFAULT ROLE 'rolle_admin' FOR 'atussa'@'localhost';
FLUSH PRIVILEGES;


-- ====================================================================
-- 3. Abschnitt: Datenbefüllung (Beispieldaten)
-- ====================================================================

-- 1. Stammdaten (Genres, Filmreihen, Personen)

INSERT INTO Genres (genreName) VALUES
('Action'),         -- ID 1
('Sci-Fi'),         -- ID 2
('Drama'),          -- ID 3
('Krimi'),          -- ID 4
('Thriller'),       -- ID 5
('Fantasy'),        -- ID 6
('Abenteuer'),      -- ID 7
('Animation'),      -- ID 8
('Krieg'),         -- ID 9
('Komödie'),       -- ID 10
('Horror'),       -- ID 11
('Dokumentation'),  -- ID 12
('Romantik');     -- ID 13

INSERT INTO Filmreihen (reihenName) VALUES
('The Dark Knight Trilogy'),    -- ID 1
('The Lord of the Rings'),      -- ID 2
('The Matrix Trilogy');         -- ID 3

INSERT INTO Personen (vorname, name) VALUES
('Christopher', 'Nolan'),   -- ID 1
('Christian', 'Bale'),      -- ID 2
('Heath', 'Ledger'),        -- ID 3
('Peter', 'Jackson'),       -- ID 4
('Elijah', 'Wood'),         -- ID 5
('Ian', 'McKellen'),        -- ID 6
('Quentin', 'Tarantino'),   -- ID 7
('John', 'Travolta'),       -- ID 8
('Samuel L.', 'Jackson'),    -- ID 9
('Uma', 'Thurman'),         -- ID 10
('Frank', 'Darabont'),      -- ID 11
('Tim', 'Robbins'),         -- ID 12
('Morgan', 'Freeman'),      -- ID 13
('David', 'Fincher'),       -- ID 14
('Brad', 'Pitt'),           -- ID 15
('Edward', 'Norton'),       -- ID 16
('Clint', 'Eastwood'),      -- ID 17
('Denis', 'Villeneuve'),    -- ID 18
('Timothée', 'Chalamet'),   -- ID 19
('Lana', 'Wachowski'),      -- ID 20
('Lilly', 'Wachowski'),     -- ID 21
('Keanu', 'Reeves'),        -- ID 22
('Laurence', 'Fishburne'),  -- ID 23
('Cillian', 'Murphy'),      -- ID 24
('Steven', 'Spielberg'),    -- ID 25
('Tom', 'Hanks'),           -- ID 26
('Matt', 'Damon'),          -- ID 27
('Martin', 'Scorsese'),     -- ID 28
('Robert', 'De Niro'),      -- ID 29
('Al', 'Pacino'),           -- ID 30
('Bong', 'Joon-ho'),        -- ID 31
('Jake', 'Gyllenhaal'),     -- ID 32
('Robert', 'Downey Jr.'),   -- ID 33
('Mark', 'Ruffalo'),        -- ID 34
('Leonardo', 'DiCaprio'),   -- ID 35
('Jack', 'Nicholson'),      -- ID 36
('Ridley', 'Scott'),        -- ID 37
('Russell', 'Crowe'),       -- ID 38
('George', 'Miller'),       -- ID 39
('Tom', 'Hardy'),           -- ID 40
('Charlize', 'Theron'),     -- ID 41
('Hugh', 'Jackman'),        -- ID 42
('Scarlett', 'Johansson'),  -- ID 43
('Joel', 'Coen'),           -- ID 44
('Ethan', 'Coen'),          -- ID 45
('Javier', 'Bardem'),       -- ID 46
('Damien', 'Chazelle'),     -- ID 47
('Miles', 'Teller'),        -- ID 48
('J.K.', 'Simmons'),        -- ID 49
('Christoph', 'Waltz'),     -- ID 50
('Francis Ford', 'Coppola');-- ID 51


-- 2. Filme (abhängig von Genres & Filmreihen)

INSERT INTO Filme (titel, erscheinungsjahr, medium, genreID, filmreiheID) VALUES
('The Dark Knight', 2008, 'Blu-ray', 1, 1),             -- Film ID 1
('Batman Begins', 2005, 'Blu-ray', 1, 1),             -- Film ID 2
('The Dark Knight Rises', 2012, 'DVD', 1, 1),          -- Film ID 3
('The Lord of the Rings: The Fellowship of the Ring', 2001, 'Blu-ray', 6, 2), -- Film ID 4
('The Lord of the Rings: The Two Towers', 2002, 'Blu-ray', 6, 2), -- Film ID 5
('The Lord of the Rings: The Return of the King', 2003, 'Blu-ray', 6, 2), -- Film ID 6
('Pulp Fiction', 1994, 'Netflix', 4, NULL),            -- Film ID 7 
('Reservoir Dogs', 1992, 'Amazon Prime', 4, NULL),     -- Film ID 8 
('The Shawshank Redemption', 1994, 'Blu-ray', 3, NULL), -- Film ID 9
('Fight Club', 1999, 'Blu-ray', 5, NULL),            -- Film ID 10
('Se7en', 1995, 'Netflix', 4, NULL),                   -- Film ID 11 
('Gran Torino', 2008, 'Blu-ray', 3, NULL),             -- Film ID 12
('Unforgiven', 1992, 'DVD', 3, NULL),                  -- Film ID 13
('Dune', 2021, '4K Blu-ray', 2, NULL),               -- Film ID 14
('Blade Runner 2049', 2017, 'Netflix', 2, NULL),       -- Film ID 15 
('The Matrix', 1999, '4K Blu-ray', 2, 3),            -- Film ID 16
('The Matrix Reloaded', 2003, 'DVD', 2, 3),            -- Film ID 17
('The Matrix Revolutions', 2003, 'DVD', 2, 3),         -- Film ID 18
('Inception', 2010, 'Blu-ray', 2, NULL),               -- Film ID 19
('Oppenheimer', 2023, '4K Blu-ray', 3, NULL),          -- Film ID 20
('Saving Private Ryan', 1998, 'Amazon Prime', 9, NULL), -- Film ID 21 
('Forrest Gump', 1994, 'Blu-ray', 3, NULL),          -- Film ID 22
('The Irishman', 2019, 'Netflix', 4, NULL),            -- Film ID 23 
('Parasite', 2019, 'Blu-ray', 5, NULL),              -- Film ID 24
('Goodfellas', 1990, 'Netflix', 4, NULL),            -- Film ID 25 
('The Godfather', 1972, '4K Blu-ray', 4, NULL),      -- Film ID 26
('Interstellar', 2014, 'Amazon Prime', 2, NULL),     -- Film ID 27
('Zodiac', 2007, 'Amazon Prime', 5, NULL),                 -- Film ID 28
('The Departed', 2006, 'Blu-ray', 4, NULL),                -- Film ID 29
('Gladiator', 2000, 'DVD', 3, NULL),                       -- Film ID 30
('Mad Max: Fury Road', 2015, '4K Blu-ray', 1, NULL),       -- Film ID 31
('The Prestige', 2006, 'Blu-ray', 5, NULL),                -- Film ID 32
('No Country for Old Men', 2007, 'Blu-ray', 4, NULL),      -- Film ID 33
('Whiplash', 2014, 'Amazon Prime', 3, NULL),               -- Film ID 34
('Inglourious Basterds', 2009, 'Blu-ray', 9, NULL),        -- Film ID 35
('The Godfather Part II', 1974, '4K Blu-ray', 4, NULL),    -- Film ID 36
('Shutter Island', 2010, 'Netflix', 5, NULL);              -- Film ID 37



-- 3. Verknüpfungen (Film_Beteiligungen) sortiert nach filmID
INSERT INTO Film_Beteiligungen (filmID, personID, istRegisseur, istSchauspieler) VALUES
(1, 1, TRUE, FALSE),  (1, 2, FALSE, TRUE),  (1, 3, FALSE, TRUE),
(2, 1, TRUE, FALSE),  (2, 2, FALSE, TRUE),
(4, 4, TRUE, FALSE),  (4, 5, FALSE, TRUE),  (4, 6, FALSE, TRUE),
(7, 7, TRUE, TRUE),   (7, 8, FALSE, TRUE),  (7, 9, FALSE, TRUE),  (7, 10, FALSE, TRUE),
(9, 11, TRUE, FALSE), (9, 12, FALSE, TRUE), (9, 13, FALSE, TRUE),
(10, 14, TRUE, FALSE),(10, 15, FALSE, TRUE),(10, 16, FALSE, TRUE),
(12, 17, TRUE, TRUE),
(14, 18, TRUE, FALSE),(14, 19, FALSE, TRUE),
(16, 20, TRUE, FALSE),(16, 21, TRUE, FALSE),(16, 22, FALSE, TRUE),(16, 23, FALSE, TRUE),
(19, 1, TRUE, FALSE), (19, 23, FALSE, TRUE),
(20, 1, TRUE, FALSE), (20, 24, FALSE, TRUE),
(21, 25, TRUE, FALSE),(21, 26, FALSE, TRUE),(21, 27, FALSE, TRUE),
(23, 28, TRUE, FALSE),(23, 29, FALSE, TRUE),(23, 30, FALSE, TRUE),
(24, 31, TRUE, FALSE),
(27, 1, TRUE, FALSE), (28, 14, TRUE, FALSE), (28, 32, FALSE, TRUE), (28, 33, FALSE, TRUE), (28, 34, FALSE, TRUE),
(29, 28, TRUE, FALSE), (29, 35, FALSE, TRUE), (29, 27, FALSE, TRUE), (29, 36, FALSE, TRUE),
(30, 37, TRUE, FALSE), (30, 38, FALSE, TRUE),
(31, 39, TRUE, FALSE), (31, 40, FALSE, TRUE), (31, 41, FALSE, TRUE),
(32, 1, TRUE, FALSE),  (32, 2, FALSE, TRUE),  (32, 42, FALSE, TRUE), (32, 43, FALSE, TRUE),
(33, 44, TRUE, FALSE), (33, 45, TRUE, FALSE), (33, 46, FALSE, TRUE),
(34, 47, TRUE, FALSE), (34, 48, FALSE, TRUE), (34, 49, FALSE, TRUE),
(35, 7, TRUE, FALSE),  (35, 15, FALSE, TRUE), (35, 50, FALSE, TRUE),
(36, 51, TRUE, FALSE), (36, 30, FALSE, TRUE), (36, 29, FALSE, TRUE),
(37, 28, TRUE, FALSE), (37, 35, FALSE, TRUE), (37, 34, FALSE, TRUE);


-- 4. Persönliche Listen (Watchlist & GeseheneFilme)
-- BenutzerIDs: 1=julian, 2=lucius, 3=atussa, 4=max, 5=lena,

INSERT INTO Watchlist (benutzerID, filmID, hinzugefuegtAm) VALUES
(1, 14, '2025-10-01'), -- Julian will 'Dune' (Film 14) sehen
(1, 15, '2025-10-02'), -- Julian will 'Blade Runner 2049' (Film 15) sehen
(1, 27, '2025-10-02'), -- Julian will 'Interstellar' (Film 27) sehen
(1, 31, '2025-10-12'), -- Julian will 'Mad Max: Fury Road' (Film 31) sehen
(1, 32, '2025-10-13'), -- Julian will 'The Prestige' (Film 32) sehen
(2, 4, '2025-10-03'),  -- Lucius will 'LOTR 1' (Film 4) sehen
(2, 5,  '2025-10-06'), -- Lucius will 'LOTR 2' (Film 5) sehen
(2, 6,  '2025-10-07'), -- Lucius will 'LOTR 3' (Film 6) sehen
(2, 27, '2025-10-08'), -- Lucius will 'Interstellar' (Film 27) sehen
(2, 35, '2025-10-09'), -- Lucius will 'Inglourious Basterds' (Film 35) sehen
(3, 10, '2025-10-04'), -- Atussa will 'Fight Club' (Film 10) sehen
(3, 22, '2025-10-12'), -- Atussa will 'Forrest Gump' (Film 22) sehen
(3, 28, '2025-10-13'), -- Atussa will 'Zodiac' (Film 28) sehen
(3, 34, '2025-10-14'), -- Atussa will 'Whiplash' (Film 34) sehen
(4, 20, '2025-10-05'), -- Max will 'Oppenheimer' (Film 20) sehen
(4, 1, '2025-10-05'),  -- Max will 'The Dark Knight' (Film 1) sehen
(5, 7, '2025-10-10'),  -- Lena will 'Pulp Fiction' (Film 7) sehen
(5, 35, '2025-10-13'), -- Lena will 'Inglourious Basterds' (Film 35) sehen
(5, 30, '2025-10-14'); -- Lena will 'Gladiator' (Film 30) sehen

INSERT INTO GeseheneFilme (benutzerID, filmID, gesehenAm, persoenlicheBewertung) VALUES
(1, 1, '2025-01-15', 9),  -- Julian hat 'The Dark Knight' (Film 1) gesehen & bewertet
(1, 9, '2025-02-20', 10), -- Julian hat 'Shawshank Redemption' (Film 9) gesehen & bewertet
(1, 19, '2025-03-10', 8), -- Julian hat 'Inception' (Film 19) gesehen & bewertet
(1, 25, '2025-04-05', 9),  -- Julian hat 'Goodfellas' (Film 25) gesehen & bewertet
(1, 26, '2025-04-25', 8),  -- Julian hat 'The Godfather' (Film 26) gesehen & bewertet
(2, 21, '2025-01-01', 9), -- Lucius hat 'Saving Private Ryan' (Film 21) gesehen & bewertet
(2, 4,  '2025-02-10', 9),  -- Lucius hat 'LOTR Fellowship' (Film 4) gesehen & bewertet
(2, 5,  '2025-02-20', 8),  -- Lucius hat 'LOTR Two Towers' (Film 5) gesehen & bewertet
(2, 6,  '2025-03-05', 10), -- Lucius hat 'LOTR Return of the King' (Film 6) gesehen & bewertet
(2, 27, '2025-03-25', 9),  -- Lucius hat 'Interstellar' (Film 27) gesehen & bewertet
(3, 12, '2025-04-12', 8), -- Atussa hat 'Gran Torino' (Film 12) gesehen & bewertet
(3, 24, '2025-02-18', 9),  -- Atussa hat 'Parasite' (Film 24) gesehen & bewertet
(3, 34, '2025-03-12', 10), -- Atussa hat 'Whiplash' (Film 34) gesehen & bewertet
(3, 22, '2025-04-01', 8),  -- Atussa hat 'Forrest Gump' (Film 22) gesehen & bewertet
(4, 10, '2025-05-05', 10), -- Max hat 'Fight Club' (Film 10) gesehen & bewertet
(4, 7, '2025-06-15', 8),  -- Max hat 'Pulp Fiction' (Film 7) gesehen & bewertet
(4, 20, '2025-07-20', 9),  -- Max hat 'Oppenheimer' (Film 20) gesehen & bewertet
(4, 21, '2025-08-05', 8),  -- Max hat 'Saving Private Ryan' (Film 21) gesehen & bewertet
(4, 28, '2025-08-25', 7),  -- Max hat 'Zodiac' (Film 28) gesehen & bewertet
(5, 10, '2025-07-01', 9), -- Lena hat 'Fight Club' (Film 10) gesehen & bewertet
(5, 16, '2025-08-01', 10), -- Lena hat 'The Matrix' (Film 16) gesehen & bewertet
(5, 32, '2025-08-15', 9),  -- Lena hat 'The Prestige' (Film 32) gesehen & bewertet
(5, 19, '2025-09-05', 10); -- Lena hat 'Inception' (Film 19) gesehen & bewertet