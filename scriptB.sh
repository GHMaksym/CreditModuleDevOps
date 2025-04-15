#!/bin/bash

# Функція для відправки HTTP-запиту
function send_request {
    url="http://localhost"
    curl -s $url > /dev/null
    echo "Запит до $url надіслано!"
}

# Випадковий інтервал для запитів від 5 до 10 секунд
while true; do
    sleep_time=$((5 + RANDOM % 6))
    send_request &
    sleep $sleep_time
done
