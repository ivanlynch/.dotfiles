IMAGE_NAME="alpine-development-environment"

# Copiar archivos de configuración preservando el punto inicial
cp -r ./../../.config ./.config

# Construir la imagen
docker build \
    --build-arg USER_UID=$(id -u) \
    --build-arg USER_GID=$(id -g) \
    --build-arg USER_NAME=$(whoami) \
    -t "$IMAGE_NAME" .

# Variables para git (opcional, modifica según tus necesidades)
GIT_USER_NAME="$(git config --get user.name)"
GIT_USER_EMAIL="$(git config --get user.email)"

# Directorio de proyecto (puedes modificarlo según tus necesidades)
WORKSPACE_DIR="$PWD"

# Ejecutar el contenedor
docker run -it --rm \
    -v "$WORKSPACE_DIR:/workspace" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e HOST_USER_ID="$(id -u)" \
    -e HOST_GROUP_ID="$(id -g)" \
    -e USER_NAME="$(whoami)" \
    -e GIT_USER_NAME="$GIT_USER_NAME" \
    -e GIT_USER_EMAIL="$GIT_USER_EMAIL" \
    -v "$HOME/.ssh:/home/$(whoami)/.ssh" \
    "$IMAGE_NAME"

