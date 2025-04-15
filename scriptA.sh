#!/bin/bash

# Масив контейнерів з командою запуску для кожного
declare -A container_commands=(
    ["srv1"]="podman run -d -p 8081:8080 --name srv1 ghmaksym/shxcalc-server:multiarch"
    ["srv2"]="podman run -d -p 8082:8080 --name srv2 ghmaksym/shxcalc-server:multiarch"
    ["srv3"]="podman run -d -p 8083:8080 --name srv3 ghmaksym/shxcalc-server:multiarch"
)

# Функція для запуску контейнера
start_container() {
    local name=$1

    echo "[INFO] Запуск контейнера $name..."

    # Видалити контейнер, якщо існує
    if podman ps -a --format "{{.Names}}" | grep -q "^$name$"; then
        echo "[WARN] Контейнер $name вже існує. Видаляю..."
        podman rm -f "$name"
    fi

    eval "${container_commands[$name]}"
}

# Функція для перевірки доступності через HTTP
check_http() {
    local name=$1
    local port=$2
    local url="http://localhost:$port"

    if curl -s --max-time 2 "$url" | grep -q "HTTP server is running"; then
        echo "[INFO] $name на порту $port — OK"
        return 0
    else
        echo "[ERROR] $name на порту $port не відповідає."
        return 1
    fi
}

# Початковий запуск контейнерів
for name in "${!container_commands[@]}"; do
    start_container "$name"
done

# Основний цикл перевірки та оновлення
while true; do
    sleep 10

    for name in "${!container_commands[@]}"; do
        # Визначаємо порт для перевірки
        case "$name" in
            srv1) port=8081 ;;
            srv2) port=8082 ;;
            srv3) port=8083 ;;
        esac

        if ! check_http "$name" "$port"; then
            echo "[INFO] Перезапуск $name..."
            start_container "$name"
        fi
    done

    echo "[INFO] Перевіряю оновлення образу..."
    podman pull ghmaksym/shxcalc-server:multiarch

    sleep 60
done

