#!/bin/bash

ACTION=$1
DEVICE_NAME=$2
MOUNT_POINT="/mnt/sd"

do_mount()
{
    # Проверяем, существует ли указанное устройство
    if [ ! -b "/dev/$DEVICE_NAME" ]; then
        echo "Error: Device /dev/$DEVICE_NAME does not exist."
        exit 1
    fi

    # Создаем точку монтирования, если она не существует
    if [ ! -d "$MOUNT_POINT" ]; then
        echo "Creating mount point at $MOUNT_POINT"
        sudo mkdir -p "$MOUNT_POINT"
    fi

    # Проверяем, смонтировано ли уже устройство
    if mount | grep -q "$MOUNT_POINT"; then
        echo "$MOUNT_POINT is already mounted."
        exit 0
    fi

    # Пытаемся монтировать устройство, выводим подробную отладку
    echo "Attempting to mount /dev/$DEVICE_NAME at $MOUNT_POINT"
    mount -v "/dev/$DEVICE_NAME" "$MOUNT_POINT"

    # Проверяем, успешно ли прошло монтирование
    if [ $? -eq 0 ]; then
        echo "Mounted /dev/$DEVICE_NAME at $MOUNT_POINT successfully."
    else
        echo "Failed to mount /dev/$DEVICE_NAME. Check device format and logs for details."
        exit 1
    fi
}

do_umount()
{
    if mount | grep -q "$MOUNT_POINT"; then
        echo "Unmounting $MOUNT_POINT..."
        umount "$MOUNT_POINT" && echo "Unmounted $MOUNT_POINT" || echo "Failed to unmount $MOUNT_POINT"
    else
        echo "$MOUNT_POINT is not mounted. Skipping unmount."
    fi
}

case "${ACTION}" in
    add)
        do_mount
        ;;
    remove)
        do_umount
        ;;
esac