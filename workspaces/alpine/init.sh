IMAGE_NAME="ivanlynch/alpine-development-environment"
TAG="latest"
CONTAINER_NAME="alpine-dev"

echo "🐳 Iniciando configuración de Alpine Development Environment..."

# Asegurarse de estar en el directorio del script
cd "$(dirname "$0")"
echo "📁 Directorio de trabajo: $(pwd)"

# Copiar archivos de configuración solo si no existen localmente
echo "⚙️  Preparando archivos de configuración..."
rm -rf .config
mkdir -p .config

# Copiar fish config
cp -r "$HOME/.config/fish" .config/
echo "🐟 Configuración de Fish copiada"

# Copiar neovim config
cp -r "$HOME/.config/nvim" .config/
echo "📝 Configuración de Neovim copiada"

# Verificar si el contenedor ya existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "📦 Contenedor $CONTAINER_NAME ya existe"
   
    # Verificar si está corriendo
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "🔄 Contenedor ya está corriendo. Conectándose..."
        echo "💡 Para conectar terminales adicionales, usa: docker exec -it $CONTAINER_NAME fish"
        docker exec -it "$CONTAINER_NAME" fish
        exit 0
    else
        echo "🚀 Iniciando contenedor existente..."
        docker start -ai "$CONTAINER_NAME"
        exit 0
    fi
fi

# Construir la imagen solo si el contenedor no existe
echo "🔨 Construyendo imagen Docker..."
docker build \
    --build-arg CACHEBUST=$(date +%s) \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    --build-arg USER_NAME=$(whoami) \
    -t "$IMAGE_NAME:$TAG" .

if [ $? -eq 0 ]; then
    echo "✅ Imagen construida exitosamente"
    
    # Solo hacer push si la construcción fue exitosa
    echo "📤 Subiendo imagen a Docker Hub..."
    docker push "$IMAGE_NAME:$TAG"
    
    if [ $? -eq 0 ]; then
        echo "✅ Imagen subida exitosamente"
    else
        echo "⚠️  Error subiendo la imagen, pero continuando..."
    fi
else
    echo "❌ Error construyendo la imagen"
    exit 1
fi

# Variables para git (opcional, modifica según tus necesidades)
echo "🔧 Configurando variables de entorno..."
GIT_USER_NAME="$(git config --get user.name)"
GIT_USER_EMAIL="$(git config --get user.email)"

# Directorio de proyecto (puedes modificarlo según tus necesidades)
WORKSPACE_DIR="$HOME/workspace"

# Ejecutar el contenedor con nombre válido
echo "🚀 Iniciando contenedor..."
echo "💡 Para conectar terminales adicionales, usa: docker exec -it $CONTAINER_NAME fish"
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -p 3000:3000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e HOST_USER_ID="$(id -u)" \
    -e HOST_GROUP_ID="$(id -g)" \
    -e USER_NAME="$(whoami)" \
    -e GIT_USER_NAME="$GIT_USER_NAME" \
    -e GIT_USER_EMAIL="$GIT_USER_EMAIL" \
    -v "$WORKSPACE_DIR:/home/$(whoami)/workspace" \
    -v "$HOME/.ssh:/home/$(whoami)/.ssh" \
    "$IMAGE_NAME:$TAG"
