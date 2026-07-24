function desktop-set -d "Cambiar sesión por defecto de LightDM"
    if test (count $argv) -eq 0
        desktop-status
        return
    end

    set -l mode $argv[1]

    # Normalizar nombre
    switch "$mode"
        case hypr hyprland
            set mode "hyprland-noctalia"
        case labwc
            # ya está bien
        case '*'
            echo "❌ Sesión desconocida: \"$mode\""
            echo "   Usa: hyprland, labwc"
            return 1
    end

    # 1. Escribir .dmrc (para DMs sin autologin)
    echo "Session=$mode" >~/.dmrc
    echo "✅ ~/.dmrc actualizado"

    # 2. Detectar si hay autologin activo
    if grep -q "^autologin-session=" /etc/lightdm/lightdm.conf 2>/dev/null
        echo ""
        echo "⚠️  Tienes autologin activo — ~/.dmrc se IGNORA."
        echo "   Ejecuta este comando para aplicar el cambio:"
        echo ""
        echo "   sudo ~/.local/bin/desktop-apply labwc"
        echo ""
        echo "   (te pedirá contraseña y modificará /etc/lightdm/lightdm.conf)"
    else
        echo ""
        echo "🔔 Cierra sesión y vuelve a iniciar para aplicar."
    end
end
