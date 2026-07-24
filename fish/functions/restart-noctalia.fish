function restart-noctalia
    quickshell kill -c noctalia-shell 2>/dev/null; and qs -c noctalia-shell -d
end
