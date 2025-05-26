#!/bin/bash

# --- Variables globales ---
DISK_DIR="$HOME/workspaces/ubuntu/cache"
CONTAINER_USER_HOME="/home/$USER"
INSTALLATION_ID="$DISK_DIR/.installation_id"
LAST_PROCESSED_COMMIT_FILE="$DISK_DIR/.last_processed_commit"
TEMP_COMMIT_FILE="/tmp/.last_processed_commit"
IMAGE_NAME="ubuntu-development-environment"

# --- Funciones de utilidad ---

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Función para verificar si un directorio existe
directory_exists() {
    [[ -d "$1" ]]
}

# Función para verificar si un archivo existe
file_exists() {
    [[ -f "$1" ]]
}

# --- Funciones principales ---

# Función para obtener el commit actual de dotfiles
get_current_commit() {
    if ! command_exists dotfiles; then
        echo "El comando dotfiles no está disponible. Usando git directamente..."
        if directory_exists "$HOME/.dotfiles"; then
            git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" log --format="%H" -n 1 2>/dev/null || echo ""
        else
            echo ""
        fi
    else
        dotfiles log --format="%H" -n 1 2>/dev/null || echo ""
    fi
}

# Función para obtener el commit anterior
get_previous_commit() {
    if file_exists "$LAST_PROCESSED_COMMIT_FILE"; then
        cat "$LAST_PROCESSED_COMMIT_FILE"
    else
        echo ""
    fi
}

# Función para preparar el directorio de caché
prepare_cache_directory() {
    if ! directory_exists "$DISK_DIR"; then
        echo "Creando directorio de caché: $DISK_DIR"
        mkdir -p "$DISK_DIR"
        chmod 755 "$DISK_DIR"
    fi
}

# Función para guardar el commit en un archivo temporal
save_commit_to_temp() {
    local commit="$1"
    if [[ -n "$commit" ]]; then
        echo "Guardando nuevo commit: $commit en $TEMP_COMMIT_FILE"
        echo "$commit" > "$TEMP_COMMIT_FILE"
        chmod 644 "$TEMP_COMMIT_FILE"
        
        if ! file_exists "$TEMP_COMMIT_FILE"; then
            echo "ERROR: No se pudo guardar el archivo de commit temporal"
            return 1
        fi
    fi
}

# Función para copiar el commit del archivo temporal al directorio de caché
copy_commit_to_cache() {
    if file_exists "$TEMP_COMMIT_FILE"; then
        echo "Copiando archivo de commit temporal al directorio de caché..."
        cp "$TEMP_COMMIT_FILE" "$LAST_PROCESSED_COMMIT_FILE"
        cp "$TEMP_COMMIT_FILE" "$INSTALLATION_ID"
        chmod 644 "$LAST_PROCESSED_COMMIT_FILE"
        chmod 644 "$INSTALLATION_ID"
        
        if ! file_exists "$LAST_PROCESSED_COMMIT_FILE"; then
            echo "ERROR: No se pudo copiar el archivo de commit al directorio de caché"
            return 1
        fi
    fi
}

# Función para preparar el contexto de build
prepare_build_context() {
    echo "Preparando ./ansible..."
    if directory_exists ./ansible; then
        echo "Eliminado directorio ansible"
        rm -rf ./ansible
    fi

    if directory_exists "$HOME/ansible"; then
        echo "Copiando directorio ansible desde $HOME/ansible a ./ansible..."
        cp -rf "$HOME/ansible" .
    else
        echo "ERROR: No se encontró el directorio ansible en $HOME"
        return 1
    fi

    echo "Preparando ./config..."
    if directory_exists ./.config; then
        echo "Eliminado directorio .config"
        rm -rf ./.config
    fi

    mkdir -p ./.config

    if directory_exists "$HOME/.config/fish"; then
        echo "Copiando directorio fish desde $HOME/.config/fish a ./.config/fish..."
        cp -rf "$HOME/.config/fish" ./.config/fish
    fi

    if directory_exists "$HOME/.config/nvim"; then
        echo "Copiando directorio nvim desde $HOME/.config/nvim a ./.config/nvim..."
        cp -rf "$HOME/.config/nvim" ./.config/nvim
    fi
}

# Función para verificar los requisitos del build
check_build_requirements() {
    if ! file_exists ./Dockerfile; then
        echo "ERROR: No se encontró el Dockerfile en el directorio actual"
        return 1
    fi

    if ! file_exists ./bootstrap.yml; then
        echo "ERROR: No se encontró el archivo bootstrap.yml en el directorio actual"
        echo "Verificando estructura del directorio:"
        ls -la .
        return 1
    fi

    if ! directory_exists ./ansible/roles; then
        echo "ERROR: No se encontró el directorio de roles de ansible"
        echo "Verificando estructura del directorio ansible:"
        ls -la ./ansible
        return 1
    fi
}

# Función para construir la imagen Docker
build_docker_image() {
    echo "Construyendo imagen Docker preconfigurada ($IMAGE_NAME)..."
    docker build . -f Dockerfile -t $IMAGE_NAME

    if [ $? -ne 0 ]; then
        echo "ERROR: El build de Docker falló. No se ejecutará el contenedor."
        return 1
    fi
}

# Función para ejecutar el contenedor Docker
run_docker_container() {
    echo "Ejecutando contenedor Docker preconfigurado con home persistente..."
    docker run --rm -it \
        -v "${DISK_DIR}:${CONTAINER_USER_HOME}/cache" \
        -e USER="$USER" \
        -e HOME=${CONTAINER_USER_HOME} \
        -u $USER \
        $IMAGE_NAME
}

# --- Tests ---

# Función para ejecutar tests
run_tests() {
    echo "Ejecutando tests..."
    
    # Test de command_exists
    if ! command_exists ls; then
        echo "ERROR: Test de command_exists falló"
        return 1
    fi
    
    # Test de directory_exists
    if ! directory_exists "$HOME"; then
        echo "ERROR: Test de directory_exists falló"
        return 1
    fi
    
    # Test de file_exists
    if ! file_exists "$HOME/.bashrc"; then
        echo "ERROR: Test de file_exists falló"
        return 1
    fi
    
    # Test de prepare_cache_directory
    prepare_cache_directory
    if ! directory_exists "$DISK_DIR"; then
        echo "ERROR: Test de prepare_cache_directory falló"
        return 1
    fi
    
    # Test de save_commit_to_temp
    if ! save_commit_to_temp "test_commit"; then
        echo "ERROR: Test de save_commit_to_temp falló"
        return 1
    fi
    
    # Test de copy_commit_to_cache
    if ! copy_commit_to_cache; then
        echo "ERROR: Test de copy_commit_to_cache falló"
        return 1
    fi
    
    echo "Todos los tests pasaron correctamente"
}

# --- Función principal ---

main() {
    # Asegurarnos de estar en el directorio correcto
    cd "$(dirname "$0")"
    
    echo "Preparando contexto de build para Docker..."
    
    # Preparar el directorio de caché
    prepare_cache_directory
    
    # Obtener commits
    CURRENT_DOTFILES_COMMIT=$(get_current_commit)
    PREVIOUS_DOTFILES_COMMIT=$(get_previous_commit)
    
    echo "Commit actual de dotfiles: $CURRENT_DOTFILES_COMMIT"
    echo "Commit previamente procesado: $PREVIOUS_DOTFILES_COMMIT"
    
    # Determinar si necesitamos actualizar
    SHOULD_UPDATE=false
    
    if [[ -z "$CURRENT_DOTFILES_COMMIT" ]] || [[ -z "$PREVIOUS_DOTFILES_COMMIT" ]]; then
        echo "No se encontró información de commits. Forzando actualización del contexto..."
        rm -f "$LAST_PROCESSED_COMMIT_FILE"
        rm -f "$INSTALLATION_ID"
        CURRENT_DOTFILES_COMMIT=""
        PREVIOUS_DOTFILES_COMMIT=""
        SHOULD_UPDATE=true
    elif [[ "$CURRENT_DOTFILES_COMMIT" != "$PREVIOUS_DOTFILES_COMMIT" ]]; then
        echo "Cambio detectado en el repositorio de dotfiles. Forzando actualización del contexto..."
        echo "Commit actual: $CURRENT_DOTFILES_COMMIT"
        echo "Commit anterior: $PREVIOUS_DOTFILES_COMMIT"
        SHOULD_UPDATE=true
    fi
    
    echo "Estado de actualización: SHOULD_UPDATE=$SHOULD_UPDATE"
    
    if [[ "$SHOULD_UPDATE" = true ]]; then
        # Preparar el contexto de build
        if ! prepare_build_context; then
            echo "ERROR: Falló la preparación del contexto de build"
            exit 1
        fi
        
        # Guardar el commit en un archivo temporal
        if ! save_commit_to_temp "$CURRENT_DOTFILES_COMMIT"; then
            echo "ERROR: Falló el guardado del commit"
            exit 1
        fi
    fi
    
    # Verificar los requisitos del build
    if ! check_build_requirements; then
        echo "ERROR: No se cumplen los requisitos del build"
        exit 1
    fi
    
    if [[ "$SHOULD_UPDATE" = true ]]; then
        # Construir la imagen Docker
        if ! build_docker_image; then
            echo "ERROR: Falló la construcción de la imagen Docker"
            exit 1
        fi
    else
        echo "Usando imagen Docker existente ($IMAGE_NAME)..."
    fi
    
    # Copiar el commit del archivo temporal al directorio de caché
    if ! copy_commit_to_cache; then
        echo "ERROR: Falló la copia del commit al directorio de caché"
        exit 1
    fi
    
    # Ejecutar el contenedor Docker
    run_docker_container
}

# --- Ejecución ---

# Si se pasa el argumento --test, ejecutar los tests
if [[ "$1" == "--test" ]]; then
    run_tests
else
    main
fi
