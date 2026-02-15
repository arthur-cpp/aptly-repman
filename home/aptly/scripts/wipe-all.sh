#!/usr/bin/env bash
set -e

echo "!!! WARNING: This will delete ALL publications, snapshots, and local repositories from Aptly !!!"
echo "It will also clear your staging debs/ directories."
read -p "Are you absolutely sure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup aborted."
    exit 1
fi

# 1. Удаляем все публикации
echo ">>> Dropping all publications..."
aptly publish list -raw | while read -r PREFIX DIST; do
    if [ "$PREFIX" = "." ]; then
        echo "Dropping publication: $DIST"
        aptly publish drop "$DIST" || true
    else
        echo "Dropping publication: $DIST from prefix $PREFIX"
        aptly publish drop "$DIST" "$PREFIX" || true
    fi
done

# 2. Удаляем все снимки
echo ">>> Dropping all snapshots..."
aptly snapshot list -raw | while read -r SNAP; do
    echo "Dropping snapshot: $SNAP"
    aptly snapshot drop "$SNAP"
done

# 3. Удаляем все локальные репозитории
echo ">>> Dropping all local repositories..."
aptly repo list -raw | while read -r REPO; do
    echo "Dropping repository: $REPO"
    aptly repo drop "$REPO"
done

# 4. Очисткаstaging-папок debs/ (опционально, но логично)
echo ">>> Cleaning up staging directories in ~/aptly/debs/..."
find "$HOME/aptly/debs" -type f \( -name "*.deb" -o -name "*.dsc" -o -name "*.tar.gz" \) -delete

# 5. Финальная очистка базы и файлов
echo ">>> Cleaning up the database and package pool..."
aptly db cleanup

echo "--------------------------------------"
echo "Done. Aptly is now clean."
