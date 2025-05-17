DROP TABLE IF EXISTS nombre_cientifico;
DROP TABLE IF EXISTS lugar;
DROP TABLE IF EXISTS fecha_path;

CREATE TABLE nombre_cientifico (
    id TEXT NOT NULL UNIQUE PRIMARY KEY,
    nombre_cientifico TEXT UNIQUE NOT NULL,
    
);

CREATE TABLE lugar (
    id TEXT NOT NULL UNIQUE PRIMARY KEY
    lugar TEXT UNIQUE NOT NULL,
    
);

CREATE TABLE fecha_path (
    fecha XT NOT NULL
    path_ TEXT NOT NULL,
    
);