function ntp_sync
    if test (id -u) -ne 0
        echo "Ejecuta con sudo"
        return 1
    end

    echo "Activando NTP..."
    timedatectl set-ntp true

    echo "Esperando sincronizacion (max 30s)..."
    for i in (seq 30)
        sleep 1
        set -l status (timedatectl status --no-pager | grep "System clock synchronized")
        if echo "$status" | grep -q "yes"
            echo "Sincronizado!"
            break
        end
        if test $i -eq 30
            echo "Timeout - verificando estado..."
        end
    end

    timedatectl set-ntp false
    echo "NTP desactivado."
    timedatectl status
end