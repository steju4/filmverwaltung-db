-- ====================================================================
-- 3. Abschnitt: Datenbefüllung (Beispieldaten)
-- ====================================================================

-- 1. Stammdaten (Genres, Filmreihen, Personen)

INSERT INTO Genres (genreName) VALUES
('Action'),         -- ID 1
('Sci-Fi'),         -- ID 2
('Drama'),          -- ID 3
('Crime'),          -- ID 4
('Thriller'),       -- ID 5
('Fantasy'),        -- ID 6
('Adventure'),      -- ID 7
('Animation'),      -- ID 8
('War');            -- ID 9

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
('Bong', 'Joon-ho');        -- ID 31


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
('Interstellar', 2014, 'Amazon Prime', 2, NULL);     -- Film ID 27 


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
(27, 1, TRUE, FALSE);


-- 4. Persönliche Listen (Watchlist & GeseheneFilme)
-- BenutzerIDs: 1=julian, 2=lucius, 3=atussa, 4=max, 5=lena,

INSERT INTO Watchlist (benutzerID, filmID, hinzugefuegtAm) VALUES
(1, 14, '2025-10-01'), -- Julian will 'Dune' (Film 14) sehen
(1, 15, '2025-10-02'), -- Julian will 'Blade Runner 2049' (Film 15) sehen
(2, 4, '2025-10-03'),  -- Lucius will 'LOTR 1' (Film 4) sehen
(3, 10, '2025-10-04'), -- Atussa will 'Fight Club' (Film 10) sehen
(4, 20, '2025-10-05'), -- Max will 'Oppenheimer' (Film 20) sehen
(4, 1, '2025-10-05'),  -- Max will 'The Dark Knight' (Film 1) sehen
(5, 7, '2025-10-10'),  -- Lena will 'Pulp Fiction' (Film 7) sehen

INSERT INTO GeseheneFilme (benutzerID, filmID, gesehenAm, persoenlicheBewertung) VALUES
(1, 1, '2025-01-15', 9),  -- Julian hat 'The Dark Knight' (Film 1) gesehen & bewertet
(1, 9, '2025-02-20', 10), -- Julian hat 'Shawshank Redemption' (Film 9) gesehen & bewertet
(1, 19, '2025-03-10', 8), -- Julian hat 'Inception' (Film 19) gesehen & bewertet
(2, 21, '2025-01-01', 9), -- Lucius hat 'Saving Private Ryan' (Film 21) gesehen & bewertet
(3, 12, '2025-04-12', 8), -- Atussa hat 'Gran Torino' (Film 12) gesehen & bewertet
(4, 10, '2025-05-05', 10), -- Max hat 'Fight Club' (Film 10) gesehen & bewertet
(4, 7, '2025-06-15', 8),  -- Max hat 'Pulp Fiction' (Film 7) gesehen & bewertet
(5, 10, '2025-07-01', 9), -- Lena hat 'Fight Club' (Film 10) gesehen & bewertet
(5, 16, '2025-08-01', 10), -- Lena hat 'The Matrix' (Film 16) gesehen & bewertet