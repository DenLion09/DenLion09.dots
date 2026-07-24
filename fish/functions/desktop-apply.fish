function desktop-apply -d "Aplicar cambio de sesión (requiere sudo)"
    if test (count $argv) -eq 0
        echo "Uso: sudo desktop-apply <hyprland|labwc>"
        return 1
    end

    set -l mode $argv[1]

    switch "$mode"
        case hypr hyprland hyprland-noctalia
            set mode "hyprland"
        case labwc
            # ya está bien
        case '*'
            echo "❌ Sesión desconocida: \"$mode\""
            return 1
    end

    # Validar que el archivo de sesión existe
    if not test -f "/usr/share/wayland-sessions/$mode.desktop"
        echo "❌ El archivo de sesión $mode.desktop no existe"
        return 1
    end

    # Respaldar lightdm.conf
    set -l conf /etc/lightdm/lightdm.conf
    if not test -f "$conf.bak"
        cp "$conf" "$conf.bak"
        echo "✅ Respaldo creado: $conf.bak"
    end

    # Cambiar autologin-session
    if grep -q "^autologin-session=" "$conf"
        sed -i "s/^autologin-session=.*/autologin-session=$mode/" "$conf"
    else
        echo "autologin-session=$mode" >>"$conf"
    end

    echo "✅ autologin-session cambiado a: $mode"
    echo ""

    # También actualizar .dmrc
    if test "$mode" = "hyprland"
        echo "Session=hyprland-noctalia" >~/.dmrc
    else
        echo "Session=$mode" >~/.dmrc
    end
    echo "✅ ~/.dmrc sincronizado"

    echo ""
    echo "🔔 Cierra sesión y vuelve a iniciar para que tome efecto."
end
