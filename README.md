Run `docker network create webservices` before `docker-compose up`

Use a `docker-compose.prod.yml` file, mine looks like this:

```
version: '3.7'

services:

  app:
    restart: always
    env_file:
      - ./env/prod/phpcensor.env

  web:
    restart: always
    env_file:
      - ./env/prod/web.env
      - ./env/prod/phpcensor.env
    environment:
      VIRTUAL_HOST: mydomain.com
      LETSENCRYPT_HOST: mydomain.com
      LETSENCRYPT_EMAIL: johndoe@domain.com

  worker:
    restart: always
    env_file:
      - ./env/prod/phpcensor.env

  db:
    restart: always
    env_file:
      - ./env/prod/database.pgsql.env

  queue:
    restart: always
```
I'm using nginx-proxy and in production env I start my containers with `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`
