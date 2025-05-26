#!/bin/bash

# Asegurarnos de estar en el directorio correcto (contexto de build de Docker)
cd "$(dirname "$0")"

echo "Preparando contexto de build para Docker..."

# --- Lógica para preparar el directorio ./ansible y ./.config basada en commit de Git ---

# Ruta a tu repositorio local de dotfiles (ajusta si es necesario)
DOTFILES_REPO_PATH="$HOME/.dotfiles"
# Archivo en el contexto de build para almacenar el último commit procesado
LAST_PROCESSED_COMMIT_FILE="./.last_dotfiles_commit"

# Verificar si el directorio de dotfiles existe y es un repo Git
if [[ -d "$DOTFILES_REPO_PATH" && -d "$DOTFILES_REPO_PATH/.git" ]]; then
    CURRENT_DOTFILES_COMMIT=$(git -C "$DOTFILES_REPO_PATH" rev-parse HEAD) # [10]
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
        [[ -d ./ansible ]] && rm -rf ./ansible
        if [[ -d $DOTFILES_REPO_PATH/ansible ]]; then # Asumiendo que 'ansible' está dentro de '.dotfiles'
            echo "Copiando directorio ansible desde $DOTFILES_REPO_PATH/ansible a ./ansible..."
            cp -rf "$DOTFILES_REPO_PATH/ansible" ./ansible
        else
            echo "ADVERTENCIA: No se encontró $DOTFILES_REPO_PATH/ansible."
        fi

        # --- Lógica para preparar el directorio ./.config ---
        echo "Preparando ./.config..."
        [[ -d ./.config ]] && rm -rf ./.config
        mkdir -p ./.config # Crear el directorio .config en el contexto de build

        # Copiar selectivamente desde $DOTFILES_REPO_PATH/.config
        if [[ -d "$DOTFILES_REPO_PATH/.config/nvim" ]]; then
            echo "Copiando .config/nvim desde $DOTFILES_REPO_PATH/.config/nvim a ./.config/nvim..."
            cp -rf "$DOTFILES_REPO_PATH/.config/nvim" ./.config/nvim
        else
            echo "ADVERTENCIA: No se encontró fuente para la configuración de Neovim en dotfiles."
        fi

        if [[ -d "$DOTFILES_REPO_PATH/.config/fish" ]]; then
            echo "Copiando .config/fish desde $DOTFILES_REPO_PATH/.config/fish a ./.config/fish..."
            cp -rf "$DOTFILES_REPO_PATH/.config/fish" ./.config/fish
        else
            echo "ADVERTENCIA: No se encontró fuente para la configuración de Fish en dotfiles."
        fi
        # ... (añade más según sea necesario para otras configuraciones en .dotfiles/.config) ...

        # Actualizar el archivo con el nuevo commit procesado
        echo "$CURRENT_DOTFILES_COMMIT" > "$LAST_PROCESSED_COMMIT_FILE"
        echo "Contexto de build actualizado."
    else
        echo "El repositorio de dotfiles no ha cambiado. Usando contexto de build existente."
    fi
else
    echo "ADVERTENCIA: El repositorio de dotfiles en $DOTFILES_REPO_PATH no se encontró o no es un repositorio Git."
    echo "Se intentará construir con el contexto existente, si lo hay, o fallará si los archivos no están."
    # Aquí podrías tener una lógica de fallback si los directorios no existen y es la primera vez.
    # Por ahora, asumimos que si no hay dotfiles, y no hay copia previa, el build podría fallar
    # si el Dockerfile espera que estos directorios existan.
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
DISK_DIR="/Users/ivanlynch/workspaces/ubuntu/disk"
CONTAINER_USER_HOME="/home/ivanlynch"
mkdir -p "${DISK_DIR}"
echo "Ejecutando contenedor Docker preconfigurado con home persistente..."
docker run --rm -it \
    -v "${DISK_DIR}:${CONTAINER_USER_HOME}" \
    $IMAGE_NAME
