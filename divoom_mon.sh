#!/bin/bash

# Проверка установленных программ
check_dependencies() {
    dependencies=("jq" "sensors" "mpstat")

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "Ошибка: Требуемая программа '$dep' не установлена."
            echo "Установите её и повторите запуск скрипта."
            exit 1
        fi
    done
}

# Получение IP устройства и его ID
get_device_info() {
    response=$(curl -s https://app.divoom-gz.com/Device/ReturnSameLANDevice)
    DevicePrivateIP=$(echo "$response" | jq -r '.DeviceList[0].DevicePrivateIP')
    DeviceId=$(echo "$response" | jq -r '.DeviceList[0].DeviceId')
}

get_cpu_usage() {
    # Получаем информацию о загрузке CPU через mpstat (1 секунда, 1 отчет)
    CpuUse=$(mpstat 1 1 | grep "Average" | awk '{printf "%.0f", 100 - $12}')
}

# Функция для получения параметров системы
get_system_info() {
    # Вычисляем использование CPU
    get_cpu_usage

    # GPU использование
    GpuUse=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits) || GpuUse="0"

    # Температура CPU
    CpuTemp=$(sensors | grep -m 1 "Tctl:" | awk '{printf "%.0f", $2}' | tr -d '+°C')

    # Температура GPU
    GpuTemp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits) || GpuTemp="0"

    # Использование RAM
    RamUse=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')

    # Использование HDD
    HardDiskUse=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
}

# Функция для отправки данных
send_data() {
    curl -s -X POST "http://$DevicePrivateIP:80/post" \
        -H "Content-Type: application/json" \
        -d '{"Command":"Device/UpdatePCParaInfo","ScreenList":[{"LcdId":'"$DeviceId"',"DispData":["'"$CpuUse"'","'"$GpuUse"'","'"$CpuTemp"'","'"$GpuTemp"'","'"$RamUse"'","'"$HardDiskUse"'"]}]}' \
        > /dev/null 2>&1
}

    # Проверяем установленные программы
    check_dependencies

    # Получаем DevicePrivateIP и DeviceId
    get_device_info

    # Проверяем успешность получения данных
    if [[ -z "$DevicePrivateIP" || -z "$DeviceId" ]]; then
        echo "Ошибка: Не удалось получить данные устройства."
        exit 1
    fi

    # Запуск основного цикла
    while true; do
        get_system_info
        send_data
        sleep 1 # время задержки между вызовами
    done