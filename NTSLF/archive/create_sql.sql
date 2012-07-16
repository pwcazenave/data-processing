-- Add data table. Make station names case insensitive.
CREATE TABLE Tides( 
    year INT, 
    month INT,
    day INT,
    hour INT,
    minute INT,
    second INT,
    elevation FLOAT(10),
    residual FLOAT(10),
    quality TEXT COLLATE nocase,
    shortName VARCHAR(32) COLLATE nocase,
    longName VARCHAR(32) COLLATE nocase
);

-- Add meta data table. Make station names case insensitive.
CREATE TABLE Stations(
    latDD FLOAT(10),
    lonDD FLOAT(10),
    shortName VARCHAR(32) COLLATE nocase,
    longName VARCHAR(32) COLLATE nocase
);

.exit
