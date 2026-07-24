function hotspot --description "Toggle WiFi hotspot on/off (create_ap)"
    set -l iface_wifi wlp0s20f3
    set -l iface_internet enp1s0
    set -l ssid MiRed
    set -l pass clave1234

    # Pedir contraseña al inicio y cachearla
    sudo -v || return 1

    if pgrep -x create_ap > /dev/null 2>&1
        echo "🟡 Apagando hotspot..."
        sudo pkill -x create_ap
        if ip link show ap0 > /dev/null 2>&1
            sudo ip link delete ap0 2>/dev/null
        end
        echo "✅ Hotspot apagado"
        return 0
    end

    # ip_forward
    if test (sudo sysctl -n net.ipv4.ip_forward) != "1"
        sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
    end

    echo "🟢 Iniciando hotspot (SSID: $ssid)..."
    sudo create_ap $iface_wifi $iface_internet $ssid $pass > /dev/null 2>&1 &

    sleep 2
    if pgrep -x create_ap > /dev/null 2>&1
        echo "✅ Hotspot activo — conectate a $ssid"
        echo "   Para apagar:  hotspot"
    else
        echo "❌ No arrancó. Revisá con:"
        echo "   sudo create_ap $iface_wifi $iface_internet $ssid $pass"
        return 1
    end
end
