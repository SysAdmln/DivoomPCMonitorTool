# DivoomPCMonitorTool

Divoom Monitor Script for system monitoring debian server.
it runs at linux system and send data to the "PC Monitor Clock" of Pixoo64 and TimeGate

Этот скрипт отправляет параметры системы (использование CPU/GPU, температура, использование RAM и диска) на устройство Divoom Pixoo64 и TimeGate.  

## Требования

Перед использованием убедитесь, что установлены следующие зависимости:  
- **jq**  
- **sensors**  
- **mpstat**  
- **nvidia-smi** (если используется GPU NVIDIA)  

Установите недостающие зависимости с помощью пакетного менеджера (например, `apt`, `yum` или `pacman`).

Пример для Debian:  
```bash
sudo apt update
sudo apt install jq lm-sensors sysstat nvidia-smi
```

## Установка и запуск

	1.	Скачайте или создайте скрипт
Сохраните скрипт в файл, например, /root/divoom_mon.sh, и сделайте его исполняемым:
```bash
chmod +x /root/divoom_mon.sh
```
	2.	Создайте systemd сервис
Создайте файл сервиса:
```bash
sudo nano /etc/systemd/system/divoom.service
```

Вставьте следующий текст:
```ini
[Unit]
Description=Divoom Monitor Script
After=network.target

[Service]
ExecStart=/root/divoom_mon.sh
Restart=always
User=root
WorkingDirectory=/root

[Install]
WantedBy=multi-user.target
```

	3.	Активируйте и запустите сервис
Выполните следующие команды:

```bash
sudo systemctl daemon-reload
sudo systemctl enable divoom.service
sudo systemctl start divoom.service
```

4.	Проверьте статус сервиса
Убедитесь, что скрипт работает:
```bash
sudo systemctl status divoom.service
```