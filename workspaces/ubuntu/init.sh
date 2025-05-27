#!/bin/bash

# --- Variables globales ---
DISK_DIR="$HOME/workspaces/ubuntu/disk"
CONTAINER_USER_HOME="/home/$USER"
LAST_PROCESSED_COMMIT_FILE="$DISK_DIR/.last_dotfiles_commit"
TEMP_COMMIT_FILE="/tmp/.last_processed_commit"
IMAGE_NAME="ubuntu-development-environment"

USER_UID=$(id -u)
USER_GID=$(id -g)
USER_NAME=$(whoami)

# --- Funciones de utilidad ---
command_exists() { command -v "$1" &> /dev/null; }
directory_exists() { [[ -d "$1" ]]; }
file_exists() { [[ -f "$1" ]]; }

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

save_commit_to_temp() {
    local commit="$1"
    [[ -z "$commit" ]] && return 1
    echo "Guardando nuevo commit: $commit en $TEMP_COMMIT_FILE" >&2
    mkdir -p "$(dirname "$TEMP_COMMIT_FILE")"
    echo "$commit" > "$TEMP_COMMIT_FILE"
    chmod 600 "$TEMP_COMMIT_FILE"
}

copy_commit_to_cache() {
    [[ ! -f "$TEMP_COMMIT_FILE" ]] && return 1
    echo "Copiando archivo de commit temporal al directorio de caché..." >&2
    mkdir -p "$(dirname "$LAST_PROCESSED_COMMIT_FILE")"
    cp -f "$TEMP_COMMIT_FILE" "$LAST_PROCESSED_COMMIT_FILE"
    chmod 600 "$LAST_PROCESSED_COMMIT_FILE"
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
}

check_build_requirements() {
    local required_files=("Dockerfile" "bootstrap.yml")
    for file in "${required_files[@]}"; do
        if ! file_exists "./$file"; then
            echo "ERROR: No se encontró $file"
            return 1
        fi
    done
}

build_docker_image() {
    echo "Construyendo imagen Docker ($IMAGE_NAME)..."
    docker build \
        --build-arg USER_UID="$USER_UID" \
        --build-arg USER_GID="$USER_GID" \
        --build-arg USER_NAME="$USER_NAME" \
        -t "$IMAGE_NAME" . || return 1
}

run_docker_container() {
    echo "Ejecutando contenedor con home persistente..." >&2
    docker run --rm -it \
        -v "$DISK_DIR/cache:/home/$USER_NAME/cache" \
        -v "$DISK_DIR/config:/home/$USER_NAME/.config" \
        -e USER="$USER_NAME" \
        -e HOME="/home/$USER_NAME" \
        -u "$USER_UID:$USER_GID" \
        -v /etc/passwd:/etc/passwd:ro \
        -v /etc/group:/etc/group:ro \
        "$IMAGE_NAME"
}

main() {
    cd "$(dirname "$0")" || exit 1
    prepare_persistent_directories
    prepare_disk_directory

    local current_commit=$(get_current_commit)
    local previous_commit=$(get_previous_commit)
    echo "Commit actual: ${current_commit:-N/A}"
    echo "Commit anterior: ${previous_commit:-N/A}"

    local should_update=false
    if [[ "$current_commit" != "$previous_commit" ]]; then
        should_update=true
        echo "Cambios detectados, actualizando contexto..."
    fi

    if [[ "$should_update" = true ]]; then
        prepare_build_context || exit 1
        check_build_requirements || exit 1
        build_docker_image || exit 1
    else
        echo "Usando imagen existente: $IMAGE_NAME"
    fi

    if [[ -n "$current_commit" ]]; then
        save_commit_to_temp "$current_commit" && copy_commit_to_cache
    fi

    run_docker_container
}

if [[ "$1" == "--test" ]]; then
    echo "Ejecutando pruebas..."
else
    main
fi
