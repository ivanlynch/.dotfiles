#!/bin/bash

# --- Variables globales ---
DISK_DIR="$HOME/workspaces/ubuntu/disk"
CONFIG_DIR="$DISK_DIR/config"
IMAGE_NAME="ubuntu-development-environment"

USER_UID=$(id -u)
USER_GID=$(id -g)
USER_NAME=$(whoami)

# --- Funciones de utilidad ---
die() { echo -e "\033[0;31m$*\033[0m" >&2; exit 1; }
info() { echo -e "\033[0;36m$*\033[0m"; }

# --- Configurar directorios persistentes ---
setup_persistent_dirs() {
    info "Configurando directorios persistentes..."
    mkdir -p "$CONFIG_DIR"/{fish,nvim}
    
    # Inicializar configuraciones si el directorio está vacío
    if [ ! -d "$CONFIG_DIR/fish" ] || [ -z "$(ls -A "$CONFIG_DIR/fish")" ]; then
        cp -r "$HOME/.config/fish" "$CONFIG_DIR/" 2>/dev/null || true
    fi
    
    if [ ! -d "$CONFIG_DIR/nvim" ] || [ -z "$(ls -A "$CONFIG_DIR/nvim")" ]; then
        cp -r "$HOME/.config/nvim" "$CONFIG_DIR/" 2>/dev/null || true
    fi
    
    sudo chown -R "$USER_UID:$USER_GID" "$DISK_DIR"
}

# --- Construir imagen Docker ---
build_image() {
    info "Construyendo imagen Docker..."
    docker build \
        --build-arg USER_UID="$USER_UID" \
        --build-arg USER_GID="$USER_GID" \
        --build-arg USER_NAME="$USER_NAME" \
        -t "$IMAGE_NAME" . || die "Error al construir la imagen"
}

# --- Ejecutar contenedor ---
run_container() {
    info "Iniciando entorno de desarrollo..."
    docker run --rm -it \
        -v "$CONFIG_DIR/fish:/home/$USER_NAME/.config/fish" \
        -v "$CONFIG_DIR/nvim:/home/$USER_NAME/.config/nvim" \
        -v "$HOME:/home/$USER_NAME/host:ro" \
        -e USER="$USER_NAME" \
        -e HOME="/home/$USER_NAME" \
        -e PATH="/home/$USER_NAME/.local/bin:$PATH" \
        -u "$USER_UID:$USER_GID" \
        "$IMAGE_NAME"
}

# --- Función principal ---
main() {
    cd "$(dirname "$0")" || die "Error al cambiar de directorio"
    
    setup_persistent_dirs
    build_image
    run_container
}

# --- Ejecución ---
main "$@"
