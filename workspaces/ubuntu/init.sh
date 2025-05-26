#!/bin/bash

# Asegurarnos de estar en el directorio correcto (contexto de build de Docker)
cd "$(dirname "$0")"

echo "Preparando contexto de build para Docker..."

# --- Lógica para preparar el directorio ./ansible y ./.config basada en commit de Git ---

# Ruta a tu repositorio local de dotfiles (ajusta si es necesario)
DISK_DIR="$HOME/workspaces/ubuntu/cache"
CONTAINER_USER_HOME="$HOME"
INSTALLATION_ID="$DISK_DIR/.installation_id"

# Verificar si el directorio de dotfiles existe y es un repo Git
if [[ -d "$INSTALLATION_ID" ]]; then
    CURRENT_DOTFILES_COMMIT=$(dotfiles log --format="%H" -n 1) # [10]
    PREVIOUS_DOTFILES_COMMIT=""

    if [[ -f "$LAST_PROCESSED_COMMIT_FILE" ]]; then
        PREVIOUS_DOTFILES_COMMIT=$(cat "$LAST_PROCESSED_COMMIT_FILE")
    fi

    echo "Commit actual de dotfiles: $CURRENT_DOTFILES_COMMIT"
    echo "Commit previamente procesado: $PREVIOUS_DOTFILES_COMMIT"

    if [[ "$CURRENT_DOTFILES_COMMIT" != "$PREVIOUS_DOTFILES_COMMIT" ]]; then
        echo "Cambio detectado en el repositorio de dotfiles. Actualizando contexto de build..."

        # --- Lógica para preparar el directorio ./ansible ---
        echo "Preparando ./ansible..."
        if [[ -d ./ansible ]]; then
		echo "Eliminado directorio ansible"
		rm -rf ./ansible
	fi

        if [[ -d ~/ansible ]]; then # Asumiendo que 'ansible' está dentro de '.dotfiles'
            echo "Copiando directorio ansible desde ~/ansible a ./ansible..."
            cp -rf ~/ansible ./ansible
        fi

        # --- Lógica para preparar el directorio ./.config ---
        echo "Preparando ./config..."
        if [[ -d ./.config ]]; then
		echo "Eliminado directorio .config"
		rm -rf ./.config
	fi

	mkdir ./.config

        if [[ -d ~/.config/fish ]]; then
            echo "Copiando directorio fish desde ~/.config/fish a ./.config/fish..."
            cp -rf ~/.config/fish ./.config/fish
        fi


        if [[ -d ~/.config/nvim ]]; then
            echo "Copiando directorio nvim desde ~/.config/nvim a ./.config/nvim..."
            cp -rf ~/.config/nvim ./.config/nvim
        fi

        echo "$CURRENT_DOTFILES_COMMIT" > "$LAST_PROCESSED_COMMIT_FILE"
        echo "$CURRENT_DOTFILES_COMMIT" > "$INSTALLATION_ID"
        echo "Contexto de build actualizado."
    else
        echo "El repositorio de dotfiles no ha cambiado. Usando contexto de build existente."
    fi
fi


# Verificar si existe el Dockerfile (ya lo tenías)
if [[ ! -f ./Dockerfile ]]; then
   echo "ERROR: No se encontró el Dockerfile en el directorio actual"
   exit 1
fi

IMAGE_NAME="ubuntu-development-environment"

echo "Construyendo imagen Docker preconfigurada ($IMAGE_NAME)..."
docker build . -f Dockerfile -t $IMAGE_NAME

if [ $? -ne 0 ]; then
    echo "ERROR: El build de Docker falló. No se ejecutará el contenedor."
    exit 1
fi

# ... (resto de tu script para ejecutar el contenedor) ...
mkdir -p "${DISK_DIR}"
echo "Ejecutando contenedor Docker preconfigurado con home persistente..."
docker run --rm -it \
    -v "${DISK_DIR}:${CONTAINER_USER_HOME}" \
    $IMAGE_NAME
