#!/bin/bash

# Asegurarnos de estar en el directorio correcto (contexto de build de Docker)
cd "$(dirname "$0")"

echo "Preparando contexto de build para Docker..."

# --- Lógica para preparar el directorio ./ansible y ./.config basada en commit de Git ---

# Ruta a tu repositorio local de dotfiles (ajusta si es necesario)
DISK_DIR="$HOME/workspaces/ubuntu/cache"
CONTAINER_USER_HOME="/home/$USER"
INSTALLATION_ID="$DISK_DIR/.installation_id"
LAST_PROCESSED_COMMIT_FILE="$DISK_DIR/.last_processed_commit"

# Verificar si el directorio de dotfiles existe y es un repo Git
if [[ ! -d "$DISK_DIR" ]]; then
    mkdir -p "$DISK_DIR"
fi

# Verificar si el comando dotfiles está disponible
if ! command -v dotfiles &> /dev/null; then
    echo "El comando dotfiles no está disponible. Usando git directamente..."
    # Intentar obtener el commit actual usando git directamente
    if [[ -d "$HOME/.dotfiles" ]]; then
        CURRENT_DOTFILES_COMMIT=$(git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" log --format="%H" -n 1 2>/dev/null || echo "")
    else
        CURRENT_DOTFILES_COMMIT=""
    fi
else
    CURRENT_DOTFILES_COMMIT=$(dotfiles log --format="%H" -n 1 2>/dev/null || echo "")
fi

PREVIOUS_DOTFILES_COMMIT=""

if [[ -f "$LAST_PROCESSED_COMMIT_FILE" ]]; then
    PREVIOUS_DOTFILES_COMMIT=$(cat "$LAST_PROCESSED_COMMIT_FILE")
fi

echo "Commit actual de dotfiles: $CURRENT_DOTFILES_COMMIT"
echo "Commit previamente procesado: $PREVIOUS_DOTFILES_COMMIT"

# Determinar si necesitamos actualizar
SHOULD_UPDATE=false

# Si no hay commit actual o previo, forzar la actualización
if [[ -z "$CURRENT_DOTFILES_COMMIT" ]] || [[ -z "$PREVIOUS_DOTFILES_COMMIT" ]]; then
    echo "No se encontró información de commits. Forzando actualización del contexto..."
    rm -f "$LAST_PROCESSED_COMMIT_FILE"
    rm -f "$INSTALLATION_ID"
    CURRENT_DOTFILES_COMMIT=""
    PREVIOUS_DOTFILES_COMMIT=""
    SHOULD_UPDATE=true
# Si hay un cambio en el commit, forzar la actualización
elif [[ "$CURRENT_DOTFILES_COMMIT" != "$PREVIOUS_DOTFILES_COMMIT" ]]; then
    echo "Cambio detectado en el repositorio de dotfiles. Forzando actualización del contexto..."
    SHOULD_UPDATE=true
fi

if [[ "$SHOULD_UPDATE" = true ]]; then
    echo "Actualizando contexto de build..."

    # --- Lógica para preparar el directorio ./ansible ---
    echo "Preparando ./ansible..."
    if [[ -d ./ansible ]]; then
        echo "Eliminado directorio ansible"
        rm -rf ./ansible
    fi

    if [[ -d "$HOME/ansible" ]]; then
        echo "Copiando directorio ansible desde $HOME/ansible a ./ansible..."
        cp -rf "$HOME/ansible" .
    else
        echo "ERROR: No se encontró el directorio ansible en $HOME"
        exit 1
    fi

    # --- Lógica para preparar el directorio ./.config ---
    echo "Preparando ./config..."
    if [[ -d ./.config ]]; then
        echo "Eliminado directorio .config"
        rm -rf ./.config
    fi

    mkdir -p ./.config

    if [[ -d "$HOME/.config/fish" ]]; then
        echo "Copiando directorio fish desde $HOME/.config/fish a ./.config/fish..."
        cp -rf "$HOME/.config/fish" ./.config/fish
    fi

    if [[ -d "$HOME/.config/nvim" ]]; then
        echo "Copiando directorio nvim desde $HOME/.config/nvim a ./.config/nvim..."
        cp -rf "$HOME/.config/nvim" ./.config/nvim
    fi

    if [[ -n "$CURRENT_DOTFILES_COMMIT" ]]; then
        echo "$CURRENT_DOTFILES_COMMIT" > "$LAST_PROCESSED_COMMIT_FILE"
        echo "$CURRENT_DOTFILES_COMMIT" > "$INSTALLATION_ID"
    fi
    echo "Contexto de build actualizado."
else
    echo "El repositorio de dotfiles no ha cambiado. Usando contexto de build existente."
fi

# Verificar si existe el Dockerfile
if [[ ! -f ./Dockerfile ]]; then
   echo "ERROR: No se encontró el Dockerfile en el directorio actual"
   exit 1
fi

# Verificar si existe el playbook de ansible
if [[ ! -f ./bootstrap.yml ]]; then
   echo "ERROR: No se encontró el archivo bootstrap.yml en el directorio actual"
   echo "Verificando estructura del directorio:"
   ls -la .
   exit 1
fi

# Verificar si existen los roles de ansible
if [[ ! -d ./ansible/roles ]]; then
   echo "ERROR: No se encontró el directorio de roles de ansible"
   echo "Verificando estructura del directorio ansible:"
   ls -la ./ansible
   exit 1
fi

IMAGE_NAME="ubuntu-development-environment"

if [[ "$SHOULD_UPDATE" = true ]]; then
    echo "Construyendo imagen Docker preconfigurada ($IMAGE_NAME)..."
    docker build . -f Dockerfile -t $IMAGE_NAME

    if [ $? -ne 0 ]; then
        echo "ERROR: El build de Docker falló. No se ejecutará el contenedor."
        exit 1
    fi
else
    echo "Usando imagen Docker existente ($IMAGE_NAME)..."
fi

mkdir -p "${DISK_DIR}"
echo "Ejecutando contenedor Docker preconfigurado con home persistente..."
docker run --rm -it \
    -v "${DISK_DIR}:${CONTAINER_USER_HOME}" \
    -e USER="$USER" \
    -e HOME=${CONTAINER_USER_HOME} \
    -u $USER \
    $IMAGE_NAME
