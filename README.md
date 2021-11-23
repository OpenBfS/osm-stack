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

## LICENSE
This project is licensed under the GPL license. See LICENSE for more details. However, parts of this project make use of software being licensed under various other free licenses. Those licenses in this repository are copyrighted by their respective authors and explicitly referenced in the specific subfolders.

