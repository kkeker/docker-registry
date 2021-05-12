# Проект Docker Registry

Registry предназначен для хранения образов двух типов:
1. **CI** - образы с длинным жизненным циклом, на их основе собираются или тестируются другие образы. Эти образы участвуют в CI-цикле.
2. **Cache** - образы с коротким жизненным циклом. Это релизные образы сборок конкретных версий компонентов приложения.

**ВНИМАНИЕ!!!**

_Данный репозиторий содержит заранее заданные домены и ключи авторизации.
Эти данные используются только для отладки и требуют изменения!_

_Данный Registry не имеет систему разделения прав на Read Only и Read/Write, все учетные записи имеют все права!_

### Системные требования:
* Операционная система: Linux
* Прикладное ПО: git, bash, docker, docker-compose, htpasswd

### Развертывание PRODUCTION:
1. `git clone https://gitlab.mydomain.ru/docker-registry.git`.
2. `cd docker-registry`.
3. Проверить учетную запись ACME (Let's Crypt) в файлах `./config/caddy/conf.d/*.conf` (проверить достоверность записи `tls user@domain.com`).
4. Проверить настройки домена в файлах `./config/caddy/conf.d/*.conf`.
5. Проверить настройки URL в файлах `./config/registry/*.yaml` секция `http.host`.
6. Удалить отладочные данные из файлов `./credentials/*.htpassword`.
7. Создать новые авторизационные данные командами:
```
    htpasswd -c -B -b ./credentials/registry-ci.htpasswd {LOGIN} {PASSWORD}
    htpasswd -c -B -b ./credentials/registry-cache.htpasswd {LOGIN} {PASSWORD}
```
8. Сделать управляющий файл исполняемым - `chmod +x ./ctl.sh`.
9. Запустить Docker-Compose проект - `./ctl.sh start`.

### После запуска:
* Для просмотра содержимого registry - перейти по ссылкам https://docker-cache.mydomain.com или https://docker-ci.mydomain.com соотвествующих registry и пройти в них авторизацию.
Данные для входа такие же, как и авторизационные данные в самих Registry (пункт 7 раздела _Развертывание PRODUCTION_).
Демонстрационные данные:
```
    CI Registry - docker-ci / 7ovlSwex7chlsep0u3hicHuWa1lblp
    Cache Registry - docker-cache / teblQlv6zospUCepRlChigoSweReje
```
* Для загрузки образов в Registry выполнить:
```
    docker login -u {LOGIN} -p {PASSWORD} docker-{ci или cache}.mydomain.com:5000
    docker tag {CURRENT_IMAGE}:{CURRENT_TAG} docker-{ci или cache}.mydomain.com:5000/{NEW_IMAGE}:{NEW_TAG}
    docker push docker-{ci или cache}.lendocorp.com:5000/{NEW_IMAGE}:{NEW_TAG}
```

### Справочник команд:
* `./ctl.sh start` - Запуск проекта.
* `./ctl.sh stop` - Остановка проекта.
* `./ctl.sh restart` - Перезапуск проекта.
* `./ctl.sh logs` - Просмотр log-вывода проекта команды `./ctl.sh start`.
* `./ctl.sh ps` - Просмотр запущенных docker-контейнеров проекта.
* `./ctl.sh debug` - Запуск проекта в режиме отладки.

### Полезные материалы:
* Информация по docker-образу сервера Caddy - https://hub.docker.com/r/abiosoft/caddy/
* Документация сервера Caddy - https://caddyserver.com/docs
* Информация по docker-образу сервера Registry Browser https://hub.docker.com/r/klausmeyer/docker-registry-browser/
* Документация сервера Registry - https://docs.docker.com/registry/configuration/

### Известные проблемы:
* Не удалось заставить работать registry с minio в качестве s3 хранилища образов.
О поддержке заявлено в документации https://docs.docker.com/registry/storage-drivers/s3/, но при попытки сделать docker push происходят циклические retry, хотя структура папок создается.
Отключение `multipart` не помогает. Открытая проблема https://github.com/docker/distribution/issues/1636
* Minio не принимает политики для bucket через `aws s3api put-bucket-policy`. Для этого надо сделать put политики с ошибкой, затем через web-интерфейс minio создать новую простую политику.
После этого через `aws s3api get-bucket-policy` можно получить нужную политику, которая была отправлена через put. Политика для S3 https://github.com/docker/docker.github.io/blob/master/registry/storage-drivers/s3.md

