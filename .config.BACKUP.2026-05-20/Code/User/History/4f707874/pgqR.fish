function pyserve
    # Usar el directorio actual o el pasado como argumento
    set -l dir $argv[1]
    if test -z "$dir"
        set dir (pwd)
    end

    # Verificar que existe el directorio
    if not test -d "$dir"
        echo "Error: El directorio '$dir' no existe"
        return 1
    end

    # Cambiar al directorio y ejecutar el servidor
    cd $dir
    python3 -m http.server 8000
end