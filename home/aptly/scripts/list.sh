#!/usr/bin/env bash

# Цвета
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BOLD}=== СОСТОЯНИЕ APTLY РЕПОЗИТОРИЕВ ===${NC}"
echo ""

# 1. Локальные репозитории
echo -e "${BLUE}--- Локальные репозитории (Local Repos) ---${NC}"
REPOS=$(aptly repo list -raw)

if [ -z "$REPOS" ]; then
    echo "Локальных репозиториев пока нет."
else
    printf "%-20s | %-10s\n" "Имя репозитория" "Пакетов"
    printf "%-20s | %-10s\n" "--------------------" "----------"
    for REPO in $REPOS; do
        # Берем число из "Number of packages: X"
        COUNT=$(aptly repo show "$REPO" | grep "Number of packages:" | awk '{print $4}')
        printf "%-20s | %-10s\n" "$REPO" "$COUNT"
    done
fi
echo ""

# 2. Публикации
echo -e "${BLUE}--- Текущие публикации (Published) ---${NC}"
PUBLISHED_RAW=$(aptly publish list -raw)

if [ -z "$PUBLISHED_RAW" ]; then
    echo "Ничего не опубликовано."
else
    printf "%-20s | %-10s | %-25s\n" "Дистрибутив" "Префикс" "Источник (Snapshot)"
    printf "%-20s | %-10s | %-25s\n" "--------------------" "----------" "-------------------------"
    
    echo "$PUBLISHED_RAW" | while read -r PREFIX DIST; do
        if [ "$PREFIX" = "." ]; then
            # Парсим строку "  main: snap-name [snapshot]"
            SNAP=$(aptly publish show "$DIST" | grep "main:" | awk '{print $2}')
        else
            SNAP=$(aptly publish show "$DIST" "$PREFIX" | grep "main:" | awk '{print $2}')
        fi
        
        [ -z "$SNAP" ] && SNAP="---"
        printf "%-20s | %-10s | %-25s\n" "$DIST" "$PREFIX" "$SNAP"
    done
fi
echo ""

# 3. Полный список пакетов
if [ "$1" == "--full" ]; then
    echo -e "${BLUE}--- Состав пакетов в репозиториях ---${NC}"
    for REPO in $REPOS; do
        # Используем твою проверенную команду поиска
        PACKAGES=$(aptly repo search "$REPO" 'Name (~ .*)' 2>/dev/null)
        echo -e "${GREEN}Репозиторий: $REPO${NC}"
        if [ -z "$PACKAGES" ]; then
            echo "  (пусто)"
        else
            echo "$PACKAGES" | sed 's/^/  /'
        fi
        echo ""
    done
fi

echo -e "${BOLD}====================================${NC}"
