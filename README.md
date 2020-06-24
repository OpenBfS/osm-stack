## Bauen der Images

	docker-compose build

## Anlegen der SSH-Keys

siehe Installationshandbuch

## Hochfahren der Container

	docker-compose up


## Dev-Monitoring

http://HOST:8080/cmk, z. B.: http://127.0.0.1:8080/cmk

User: 'cmkadmin'
Passwort siehe docker-compose.yml: grep CMK_PASSWORD docker-compose.yml
