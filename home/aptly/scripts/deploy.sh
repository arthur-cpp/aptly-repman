#!/bin/bash
set -e

# ==============================================================================
# Скрипт автоматического деплоя пакетов в Aptly
# Проходит по папкам в ~/aptly/debs/, импортирует пакеты и обновляет публикации.
# ==============================================================================

ROOT_DEBS_PATH="$HOME/aptly/debs"

# Проверка наличия корневой директории
if [ ! -d "$ROOT_DEBS_PATH" ]; then
    echo "Ошибка: Директория $ROOT_DEBS_PATH не найдена."
    exit 1
fi

echo ">>> Запуск процесса деплоя..."

# Проходим по всем подпапкам в debs/
for DIST_DIR in "$ROOT_DEBS_PATH"/*/; do
    
    # Получаем чистое имя папки (например, debian12)
    DIST_NAME=$(basename "$DIST_DIR")
    
    # Проверяем, есть ли файлы для обработки (.deb, .dsc, .tar.gz)
    # Это предотвращает создание пустых снэпшотов
    FILES_TO_PROCESS=$(find "$DIST_DIR" -maxdepth 1 -type f \( -name "*.deb" -o -name "*.dsc" -o -name "*.tar.gz" \))
    
    if [ -z "$FILES_TO_PROCESS" ]; then
        # Просто тихо пропускаем пустые папки
        continue
    fi

    echo "------------------------------------------------------------"
    echo "Обработка дистрибутива: $DIST_NAME"
    echo "------------------------------------------------------------"

    REPO_NAME="$DIST_NAME"

    # Маппинг имен папок в кодовые имена (Codenames)
    case "$DIST_NAME" in
        "debian11")
            CODENAMES=("debian11" "bullseye")
            ;;
        "debian12")
            CODENAMES=("debian12" "bookworm")
            ;;
        "debian13")
            CODENAMES=("debian13" "trixie")
            ;;
        "ubuntu20.04")
            CODENAMES=("ubuntu20.04" "focal")
            ;;
        "ubuntu22.04")
            CODENAMES=("ubuntu22.04" "jammy")
            ;;
        "ubuntu24.04")
            CODENAMES=("ubuntu24.04" "noble")
            ;;
        *)
            echo "Предупреждение: Папка '$DIST_NAME' не описана в скрипте. Пропускаю."
            continue
            ;;
    esac

    TIMESTAMP=$(date +%Y%m%d-%H%M)
    SNAP_NAME="snap-$REPO_NAME-$TIMESTAMP"

    # 1. Добавляем пакеты в локальный репозиторий Aptly
    echo ">>> Добавление пакетов в репозиторий $REPO_NAME..."
    aptly repo add "$REPO_NAME" "$DIST_DIR"

    # 2. Создаем снэпшот текущего состояния репозитория
    echo ">>> Создание снэпшота: $SNAP_NAME"
    aptly snapshot create "$SNAP_NAME" from repo "$REPO_NAME"

    # 3. Обновляем публикацию для каждого кодового имени
    for CODENAME in "${CODENAMES[@]}"; do
        if aptly publish list -raw | grep -q "^. $CODENAME$"; then
            echo ">>> [Publish] Переключение $CODENAME на новый снэпшот $SNAP_NAME"
            aptly publish switch "$CODENAME" "$SNAP_NAME"
        else
            echo ">>> [Publish] Первая публикация $CODENAME (снэпшот $SNAP_NAME)"
            aptly publish snapshot -distribution="$CODENAME" "$SNAP_NAME"
        fi
    done

    # 4. Очистка исходной папки (удаляем только файлы пакетов)
    echo ">>> Очистка папки $DIST_NAME от обработанных файлов..."
    find "$DIST_DIR" -maxdepth 1 -type f \( -name "*.deb" -o -name "*.dsc" -o -name "*.tar.gz" \) -delete

    echo ">>> Успешно завершено для $DIST_NAME"
    echo ""
done

echo "============================================================"
echo "Все доступные пакеты успешно задеплоены в Aptly."
