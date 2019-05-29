DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;
PRAGMA foreign_keys = ON;

-- add users table has fname, lname


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);
-- add questions table, has title and body, and author (foreign key)

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY(author_id) REFERENCES users(id)
);

-- add questions follows table, has user_id, question_id, 

CREATE TABLE question_follows (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id)  REFERENCES questions(id)
);

-- add replies table, question_id, reply_id, user_id, body

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  reply_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (reply_id) REFERENCES replies(id)
);

-- add question_likes table, has likes, user_id, question_id

CREATE TABLE question_likes (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Alex', 'Yang'),
  ('Omar', 'Abbasi'),
  ('Bobby', 'Tables'),
  ('Jimmy', 'John');

INSERT INTO 
  questions (title, body, author_id)
VALUES
  ('Is boolean?', 'Is like supposed to be a boolean?', (
    SELECT
      id
    FROM
      users
    WHERE
      fname = 'Alex'
  )),
  ('Bathroom', 'Where is the bathroom?', (SELECT id FROM users WHERE fname = 'Bobby')),
  ('Fast', 'How fast?', (SELECT id FROM users WHERE fname = 'Jimmy'));

INSERT INTO 
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Alex'), 
  (SELECT id FROM questions WHERE title = 'Is boolean?')),
  ((SELECT id FROM users WHERE fname = 'Omar'), 
  (SELECT id FROM questions WHERE title = 'Fast')),
  ((SELECT id FROM users WHERE fname = 'Jimmy'), 
  (SELECT id FROM questions WHERE title = 'Bathroom'));

INSERT INTO 
  replies(body, question_id, user_id, reply_id)
VALUES
  ('Yes!', (SELECT id FROM questions WHERE title = 'Is boolean?') 
  , (SELECT id FROM users WHERE fname = 'Omar'), NULL),
  ('Freaky Fast', (SELECT id FROM questions WHERE title = 'Fast') 
  , (SELECT id FROM users WHERE fname = 'Jimmy'), NULL),
  ('WOW', (SELECT id FROM questions WHERE title = 'Fast') 
  , (SELECT id FROM users WHERE fname = 'Bobby'), 2);

INSERT INTO 
  question_likes(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Alex'), 
  (SELECT id FROM questions WHERE title = 'Is boolean?')),
  ((SELECT id FROM users WHERE fname = 'Alex'), 
  (SELECT id FROM questions WHERE title = 'Fast')),
  ((SELECT id FROM users WHERE fname = 'Jimmy'), 
  (SELECT id FROM questions WHERE title = 'Fast')),
  ((SELECT id FROM users WHERE fname = 'Bobby'), 
  (SELECT id FROM questions WHERE title = 'Is boolean?')),
  ((SELECT id FROM users WHERE fname = 'Omar'), 
  (SELECT id FROM questions WHERE title = 'Is boolean?')),  
  ((SELECT id FROM users WHERE fname = 'Omar'), 
  (SELECT id FROM questions WHERE title = 'Bathroom'))
  ;




