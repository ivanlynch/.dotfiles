#!/bin/bash

# --- Variables globales ---
DISK_DIR="$HOME/workspaces/ubuntu/disk"
CONTAINER_USER_HOME="/home/$USER"
LAST_PROCESSED_COMMIT_FILE="$DISK_DIR/.last_dotfiles_commit"
IMAGE_NAME="ubuntu-development-environment"

USER_UID=$(id -u)
USER_GID=$(id -g)
USER_NAME=$(whoami)

# --- Funciones de utilidad ---
command_exists() {
    command -v "$1" &> /dev/null
}

directory_exists() {
    [[ -d "$1" ]]
}

file_exists() {
    [[ -f "$1" ]]
}

# --- Funciones principales ---
prepare_persistent_directories() {
    mkdir -p "$DISK_DIR"
    echo "Directorios persistentes preparados (permisos manejados por UID/GID del host)"
}

get_current_commit() {
    if ! command_exists dotfiles; then
        echo "El comando dotfiles no está disponible. Usando git directamente..." >&2
        if directory_exists "$HOME/.dotfiles"; then
            git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" log --format="%H" -n 1 2>/dev/null || echo ""
        else
            echo ""
        fi
    else
        dotfiles log --format="%H" -n 1 2>/dev/null || echo ""
    fi
}

get_previous_commit() {
    if file_exists "$LAST_PROCESSED_COMMIT_FILE"; then
        echo "Leyendo commit anterior desde: $LAST_PROCESSED_COMMIT_FILE" >&2
        cat "$LAST_PROCESSED_COMMIT_FILE"
    else
        echo ""
    fi
}

prepare_disk_directory() {
    if ! directory_exists "$DISK_DIR"; then
        echo "Creando directorio de caché: $DISK_DIR"
        mkdir -p "$DISK_DIR"
        chmod 700 "$DISK_DIR"
    fi
}


prepare_build_context() {
    echo "Preparando contexto de build..."
    rm -rf ./ansible ./.config
    mkdir -p ./.config
    if directory_exists "$HOME/ansible"; then
        echo "Copiando Ansible desde $HOME/ansible a $(pwd)/ansible"
        cp -rf "$HOME/ansible" .
    fi
    if directory_exists "$HOME/.config/fish"; then
        echo "Copiando configuración de Fish desde $HOME/.config/fish a $(pwd)/.config/fish"
        cp -rf "$HOME/.config/fish" ./.config/
    fi
    if directory_exists "$HOME/.config/nvim"; then
        echo "Copiando configuración de Neovim desde $HOME/.config/nvim a $(pwd)/.config/nvim"
        cp -rf "$HOME/.config/nvim" ./.config/
    fi

    echo "$(ls -la .config)"
}

check_build_requirements() {
    local required_files=("Dockerfile" "bootstrap.yml" ".config/fish/config.fish" ".config/nvim/init.lua")
    for file in "${required_files[@]}"; do
        if ! file_exists "./$file"; then
            echo "ERROR: No se encontró $file"
            return 1
        fi
    done
}

build_docker_image() {
    echo "Construyendo imagen Docker ($IMAGE_NAME)..."
    echo "Usando UID: $USER_UID, GID: $USER_GID, Usuario: $USER_NAME"

    docker build \
        --build-arg USER_UID="$USER_UID" \
        --no-cache \
        --progress=plain \
        --build-arg USER_GID="$USER_GID" \
        --build-arg USER_NAME="$USER_NAME" \
        -t "$IMAGE_NAME" . || return 1
}

run_docker_container() {
    echo "Ejecutando contenedor $IMAGE_NAME" >&2

    docker run --rm -it \
        -v "$DISK_DIR:/home/$USER_NAME" \
        -e USER="$USER_NAME" \
        -e HOME="/home/$USER_NAME" \
        -u "$USER_UID:$USER_GID" \
        "$IMAGE_NAME"
}

# --- Función principal ---
main() {
    cd "$(dirname "$0")" || exit 1
    
    # Preparar directorios persistentes
    prepare_persistent_directories
    prepare_disk_directory

    # Gestión de commits
    local current_commit=$(get_current_commit)
    local previous_commit=$(get_previous_commit)
    echo "Commit actual: ${current_commit:-N/A}"
    echo "Commit anterior: ${previous_commit:-N/A}"

    # Determinar necesidad de actualización
    local should_update=false
    if [[ "$current_commit" != "$previous_commit" ]]; then
        should_update=true
        echo "Cambios detectados, actualizando contexto..."
    fi

    # Construir imagen si es necesario
    if [[ "$should_update" = true ]]; then
        prepare_build_context || exit 1
        check_build_requirements || exit 1
        build_docker_image || exit 1
    else
        echo "Usando imagen existente: $IMAGE_NAME"
    fi

    # Guardar commit actual
    if [[ -n "$current_commit" ]]; then
        echo "$current_commit" > "$LAST_PROCESSED_COMMIT_FILE"
    fi

    # Ejecutar contenedor
    run_docker_container
}

# --- Ejecución ---
if [[ "$1" == "--test" ]]; then
    echo "Ejecutando pruebas..."
else
    main
fi
