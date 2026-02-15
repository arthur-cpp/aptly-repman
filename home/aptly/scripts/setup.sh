#!/bin/bash
set -e

# Список актуальных дистрибутивов
DISTS=("debian11" "debian12" "debian13" "ubuntu20.04" "ubuntu22.04" "ubuntu24.04")

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

echo "------------------------------------------------------------"
echo "Настройка завершена успешно!"
echo "Теперь ты можешь закидывать пакеты в ~/aptly/debs/ и запускать deploy.sh"
