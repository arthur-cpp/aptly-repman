# Aptly Repository Manager

Набор скриптов и конфигураций для развертывания собственного APT-репозитория с поддержкой множества дистрибутивов (Debian/Ubuntu) и интеграцией с Nginx/Cloudflare.

## Структура проекта

* `home/aptly` — Скрипты управления и папки для входящих пакетов.
* `root/aptly` — Конфигурация Aptly и публичная директория (корень веб-сервера).
* `nginx/` — Конфигурация Nginx и SSL сертификаты.

## Установка

### 1. Установка Aptly (Debian 12)

```bash
curl -fsSL [https://www.aptly.info/pubkey.txt](https://www.aptly.info/pubkey.txt) | gpg --dearmor | tee /usr/share/keyrings/aptly.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/aptly.gpg] [http://repo.aptly.info/release](http://repo.aptly.info/release) bookworm main" | tee /etc/apt/sources.list.d/aptly.list
apt update && apt install aptly nginx php-fpm lsb-release
```

### 2. Развертывание структуры

Скопируйте файлы в соответствующие директории (будьте внимательны с путями):

```bash
# Скрипты и входящие пакеты
cp -r home/aptly ~/
chmod +x ~/aptly/scripts/*.sh

# Корень репозитория и конфиг
sudo mkdir -p /aptly
sudo cp -r root/aptly/* /aptly/
cp root/aptly/aptly.conf ~/.aptly.conf

# Конфигурация Nginx
sudo cp -r nginx/* /etc/nginx/
```

### 3. Настройка ключей и доступа

1. **GPG Ключ:** Убедитесь, что у вас есть GPG ключ для подписи. Экспортируйте его публичную часть для клиентов:
   ```bash
   gpg --armor --export your-email@example.com > /aptly/public/public.key
   ```
2. **SSL:** Разместите ваши SSL сертификаты в `/etc/nginx/ssl/` (файлы `repo.site.pem` и `repo.site.key`).
3. **Cloudflare:** Обновите `/etc/nginx/conf.d/cloudflare_ips.conf`, если используете проксирование.
4. **PHP-FPM:** Проверьте версию PHP в `/etc/nginx/sites-available/repo.site`. По умолчанию прописан `php8.2-fpm.sock`.

### 4. Настройка разрешенных IP (Whitelist)

Доступ к репозиторию ограничен. Вам необходимо добавить разрешенные IP-адреса в двух местах:

1. **Для веб-интерфейса (PHP):** Отредактируйте `/aptly/allowed.php`:
   ```php
   $allowed_ips = [
       "127.0.0.1",
       "ваша_рабочая_станция",
       "ваш_сервер_деплоя"
   ];
   ```
2. **Для APT-клиентов (Nginx):** Отредактируйте `/etc/nginx/sites-available/repo.site`. В блоке `location ~ ^/(dists|pool)/` добавьте нужные IP:
   ```nginx
   allow 127.0.0.1;
   allow ваша_подсеть_или_ip;
   deny all;
   ```
   После правок выполните `sudo nginx -s reload`.

## Использование

### Начальная настройка
Создайте необходимые папки и инициализируйте локальные репозитории:
```bash
bash ~/aptly/scripts/setup.sh
```

### Деплой пакетов
1. Загрузите `.deb` файлы в соответствующие папки: `~/aptly/debs/{debian12, ubuntu22.04, ...}/`.
2. Запустите основной скрипт деплоя:
```bash
bash ~/aptly/scripts/deploy.sh
```
Скрипт импортирует пакеты, создаст снэпшоты, обновит публикации (включая алиасы типа `bookworm` или `jammy`) и очистит папку `debs/`.

### Просмотр состояния
Сводная информация по репозиториям и публикациям:
```bash
bash ~/aptly/scripts/list.sh
```
Для просмотра детального списка всех пакетов используйте:
```bash
bash ~/aptly/scripts/list.sh --full
```

### Полный сброс
Для очистки всей базы Aptly, всех публикаций и снэпшотов:
```bash
bash ~/aptly/scripts/wipe-all.sh
```

## Безопасность
* Публичный ключ доступен по адресу `https://repo.site/public.key`.
* Проверить текущий статус доступа можно через `https://repo.site/check/`.
* Основная директория данных: `/aptly`. Все изменения конфигурации Aptly вносятся в `~/.aptly.conf`.