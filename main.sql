DROP DATABASE IF EXISTS filmverwaltung;
CREATE DATABASE filmverwaltung;
USE filmverwaltung;

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
    
    -- Mindestens eine Rolle muss zugewiesen sein
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