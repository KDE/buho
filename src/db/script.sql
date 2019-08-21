
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
PRIMARY KEY(server, stamp)
FOREIGN KEY(id) REFERENCES NOTES(id)
);

CREATE TABLE IF NOT EXISTS BOOKS (
id TEXT PRIMARY KEY,
url TEXT,
title TEXT NOT NULL,
favorite INT,
adddate DATE,
modified DATE
);

CREATE TABLE IF NOT EXISTS BOOKLETS (
id TEXT,
book TEXT,
url TEXT,
title TEXT NOT NULL,
adddate DATE,
modified DATE
PRIMARY KEY(id, book)
FOREIGN KEY(book) REFERENCES BOOKS(id)
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
