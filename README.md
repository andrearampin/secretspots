Start the containers

```
docker-compose up
```

Create the `users` table and add a user
```
CREATE EXTENSION pgcrypto;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

INSERT INTO users (email, password) VALUES (
  'andrea@test.com',
  crypt('andrea', gen_salt('bf'))
);
```

Hit the endpoint

```
curl -X POST \
  http://localhost:3000/login \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d '{"email": "andrea@test.com", "password": "andrea"}'
```
