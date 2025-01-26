#!/bin/bash

# Проверяем, не пуст ли файл license-host.key, и перезаписываем license.key
if [[ -s /yougile/license-host.key ]]; then
    cat /yougile/license-host.key > /yougile/license.key
fi

# Запускаем сервер в фоновом режиме
./server &
SERVER_PID=$!

# Ждём 10 секунд
sleep 10

# Перезаписываем machine.key в machine-host.key
cat /yougile/machine.key > /yougile/machine-host.key

# Ожидаем завершения сервера
wait $SERVER_PID
