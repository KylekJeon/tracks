CREATE TABLE kittens (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  color VARCHAR(255) NOT NULL,
  breed VARCHAR(255) NOT NULL
);

INSERT INTO
  kittens (id, name, color, breed)
VALUES
  (1, "Rain", "Silver White", "Abyssinian"),
  (2, "Cleo", "Silver White", "Abyssinian"),
  (3, "Shadow", "Dark Grey", "Russian Blue"),
  (4, "Gary", "Silver White", "Tabby");
