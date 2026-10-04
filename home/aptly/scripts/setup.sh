#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/dists.sh"

echo ">>> Начинаю первичную настройку Aptly..."

# 1. Создаем структуру папок
echo ">>> Создание директорий в ~/aptly/debs/..."
for DIST in "${DISTS[@]}"; do
    mkdir -p "$HOME/aptly/debs/$DIST"
done

# 2. Создаем локальные репозитории в Aptly
echo ">>> Проверка и создание репозиториев Aptly..."

# Получаем список уже существующих репозиториев, чтобы не пытаться создать их дважды
EXISTING_REPOS=$(aptly repo list -raw)

for DIST in "${DISTS[@]}"; do
    if echo "$EXISTING_REPOS" | grep -q "^$DIST$"; then
        echo " [OK] Репозиторий '$DIST' уже существует."
    else
        echo " [++] Создание репозитория '$DIST'..."
        # Используем -component=main для порядка
        aptly repo create -component=main "$DIST"
    fi
done

# 3. Гарантируем, что каждый кодовое имя опубликовано (даже без пакетов),
# иначе клиент получает 404 на Release вместо пустого, но валидного репозитория.
echo ">>> Проверка публикаций (включая пустые репозитории)..."

for DIST in "${DISTS[@]}"; do
    EXISTING_PUBLISH=$(aptly publish list -raw)
    MISSING_CODENAMES=()
    for CODENAME in $(codenames_for "$DIST"); do
        if echo "$EXISTING_PUBLISH" | grep -q "^\. $CODENAME$"; then
            echo " [OK] '$CODENAME' уже опубликован."
        else
            MISSING_CODENAMES+=("$CODENAME")
        fi
    done

    if [ "${#MISSING_CODENAMES[@]}" -eq 0 ]; then
        continue
    fi

    TIMESTAMP=$(date +%Y%m%d-%H%M)
    SNAP_NAME="snap-$DIST-init-$TIMESTAMP"
    echo " [++] Создание начального снэпшота '$SNAP_NAME' (репозиторий '$DIST' может быть пустым)..."
    aptly snapshot create "$SNAP_NAME" from repo "$DIST"

    for CODENAME in "${MISSING_CODENAMES[@]}"; do
        echo " [++] Первая публикация '$CODENAME' (снэпшот $SNAP_NAME)..."
        # Для пустого снэпшота aptly не может определить архитектуры сам,
        # и этот список нельзя изменить после публикации — указываем явно.
        aptly publish snapshot -architectures=amd64 -distribution="$CODENAME" "$SNAP_NAME"
    done
done

echo "------------------------------------------------------------"
echo "Настройка завершена успешно!"
echo "Теперь ты можешь закидывать пакеты в ~/aptly/debs/ и запускать deploy.sh"
