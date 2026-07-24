function desktop-status -d "Mostrar sesión configurada en LightDM"
    echo "── ~/.dmrc ──────────────────────"
    if test -f ~/.dmrc
        set -l session (grep "^Session=" ~/.dmrc | string split "=" -f2)
        echo "   Sesión: $session"
    else
        echo "   (no existe)"
    end

    echo "── autologin (lightdm.conf) ─────"
    if grep -q "^autologin-session=" /etc/lightdm/lightdm.conf 2>/dev/null
        set -l auto (grep "^autologin-session=" /etc/lightdm/lightdm.conf | string split "=" -f2)
        echo "   Sesión autologin: $auto"
        echo ""
        echo "   ⚠️  El autologin tiene prioridad sobre ~/.dmrc"
        echo "   Usa: sudo desktop-apply labwc   (para cambiar)"
    else
        echo "   (sin autologin)"
        echo ""
        echo "   ✅ Aquí sí aplica ~/.dmrc"
    end

    echo "── sesiones disponibles ──────────"
    ls /usr/share/wayland-sessions/*.desktop 2>/dev/null | sed 's|.*/||; s|\.desktop||' | while read s
        echo "   - $s"
    end
end
