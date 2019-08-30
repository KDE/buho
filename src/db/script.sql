CREATE TABLE IF NOT EXISTS NOTES (
id TEXT PRIMARY KEY,
title TEXT,
url TEXT,
color TEXT,
favorite INT,
pin INT,
adddate DATE,
modified DATE
);

CREATE TABLE IF NOT EXISTS NOTES_SYNC (
id TEXT,
server TEXT,
user TEXT,
stamp TEXT,
PRIMARY KEY(server, stamp),
FOREIGN KEY(id) REFERENCES NOTES(id)
);

CREATE TABLE IF NOT EXISTS BOOKS (
title TEXT PRIMARY KEY,
url TEXT,
favorite INT,
adddate DATE,
modified DATE
);

CREATE TABLE IF NOT EXISTS BOOKLETS (
id TEXT,
book TEXT,
url TEXT,
title TEXT NOT NULL,
favorite INT,
adddate DATE,
modified DATE,
PRIMARY KEY(id, book),
FOREIGN KEY(book) REFERENCES BOOKS(title)
);

CREATE TABLE IF NOT EXISTS BOOKLETS_SYNC (
id TEXT,
server TEXT,
user TEXT,
stamp TEXT,
PRIMARY KEY(server, stamp),
FOREIGN KEY(id) REFERENCES BOOKLETS(id)
);

CREATE TABLE IF NOT EXISTS LINKS (
url TEXT PRIMARY KEY,
title TEXT,
preview TEXT,
color TEXT,
favorite INT,
pin INT,
adddate DATE,
modified DATE
);
