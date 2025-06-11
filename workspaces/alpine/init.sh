IMAGE_NAME="ivanlynch/alpine-development-environment"
TAG="latest"
CONTAINER_NAME="alpine-dev"
BUILD_CACHE_FILE=".build_cache"

# Verificar si se solicita forzar rebuild
FORCE_REBUILD=false
if [ "$1" = "--rebuild" ] || [ "$1" = "-r" ]; then
    FORCE_REBUILD=true
    echo "🔄 Forzando rebuild de la imagen..."
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "🐳 Alpine Development Environment"
    echo ""
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  -r, --rebuild    Forzar rebuild de la imagen Docker"
    echo "  -h, --help       Mostrar esta ayuda"
    echo ""
    echo "El script detecta automáticamente cambios en:"
    echo "  - Dockerfile"
    echo "  - entrypoint.sh"
    echo "  - Configuraciones de Fish (~/.config/fish)"
    echo "  - Configuraciones de Neovim (~/.config/nvim)"
    echo ""
    exit 0
fi

echo "🐳 Iniciando configuración de Alpine Development Environment..."

# Asegurarse de estar en el directorio del script
cd "$(dirname "$0")"
echo "📁 Directorio de trabajo: $(pwd)"

# Copiar archivos de configuración SIEMPRE antes de iniciar el contenedor
rm -rf .config
mkdir -p .config

# Copiar fish config
if [ -d "$HOME/.config/fish" ]; then
    cp -r "$HOME/.config/fish" .config/
    echo "🐟 Configuración de Fish copiada"
fi

# Copiar neovim config
if [ -d "$HOME/.config/nvim" ]; then
    cp -r "$HOME/.config/nvim" .config/
    echo "📝 Configuración de Neovim copiada"
fi

# Función para calcular hash de todo el contenido de la carpeta alpine
calculate_build_hash() {
    find . -type f \
        ! -name '.build_cache' \
        ! -name 'init.sh' \
        -exec cat {} + | shasum -a 256 | cut -d' ' -f1
}

# Función para verificar si necesitamos rebuild
needs_rebuild() {
    # Si se fuerza rebuild, siempre rebuildeamos
    if [ "$FORCE_REBUILD" = true ]; then
        echo "🔨 Rebuild forzado por parámetro --rebuild"
        return 0
    fi

    local current_hash=$(calculate_build_hash)
    echo "🔍 Hash actual: $current_hash"

    # Si no existe archivo de cache, necesitamos rebuild
    if [ ! -f "$BUILD_CACHE_FILE" ]; then
        echo "📝 No existe archivo de cache, creando uno nuevo"
        echo "$current_hash" >"$BUILD_CACHE_FILE"
        return 0
    fi

    # Comparar hash actual con el guardado
    local cached_hash=$(cat "$BUILD_CACHE_FILE" 2>/dev/null || echo "")
    echo "💾 Hash guardado: $cached_hash"

    if [ "$current_hash" != "$cached_hash" ]; then
        echo "🔄 Detectados cambios en configuración"
        echo "$current_hash" >"$BUILD_CACHE_FILE"
        return 0
    fi

    # Verificar si la imagen existe localmente
    if ! docker image inspect "$IMAGE_NAME:$TAG" >/dev/null 2>&1; then
        echo "📦 Imagen no existe localmente, necesario rebuild"
        return 0
    fi

    echo "✅ No se detectaron cambios, usando imagen existente"
    return 1
}

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

# Verificar si necesitamos hacer rebuild
if needs_rebuild; then
    echo "🔨 Construyendo nueva imagen..."

    # Calcular hash de configuraciones para invalidar cache de Docker
    config_hash=$(calculate_build_hash)

    echo "🔨 Construyendo imagen Docker..."
    docker build \
        --build-arg CONFIG_HASH="$config_hash" \
        --build-arg USER_ID=$(id -u) \
        --build-arg GROUP_ID=$(id -g) \
        --build-arg USER_NAME=$(whoami) \
        -t "$IMAGE_NAME:$TAG" .

    if [ $? -eq 0 ]; then
        echo "✅ Imagen construida exitosamente"

        # Solo hacer push si se especifica explícitamente
        if [ "$PUSH_IMAGE" = "true" ]; then
            echo "📤 Subiendo imagen a Docker Hub..."
            docker push "$IMAGE_NAME:$TAG"

            if [ $? -eq 0 ]; then
                echo "✅ Imagen subida exitosamente"
            else
                echo "⚠️  Error subiendo la imagen, pero continuando..."
            fi
        fi
    else
        echo "❌ Error construyendo la imagen"
        exit 1
    fi
else
    echo "✅ No se detectaron cambios, usando imagen existente"
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
