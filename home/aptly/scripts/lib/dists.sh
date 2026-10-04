#!/usr/bin/env bash
# Общий список дистрибутивов и их кодовых имён (codenames) для публикации.
# Используется setup.sh и deploy.sh — правь мапинг только здесь.

DISTS=("debian11" "debian12" "debian13" "ubuntu20.04" "ubuntu22.04" "ubuntu24.04" "ubuntu26.04")

# Возвращает список кодовых имён для публикации данного дистрибутива через stdout.
codenames_for() {
    local dist="$1"
    case "$dist" in
        "debian11")
            echo "debian11 bullseye"
            ;;
        "debian12")
            echo "debian12 bookworm"
            ;;
        "debian13")
            echo "debian13 trixie"
            ;;
        "ubuntu20.04")
            echo "ubuntu20.04 focal"
            ;;
        "ubuntu22.04")
            echo "ubuntu22.04 jammy"
            ;;
        "ubuntu24.04")
            echo "ubuntu24.04 noble"
            ;;
        "ubuntu26.04")
            echo "ubuntu26.04 resolute"
            ;;
        *)
            return 1
            ;;
    esac
}
