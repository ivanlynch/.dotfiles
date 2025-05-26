#!/bin/bash

# Asegurarnos de estar en el directorio correcto
cd "$(dirname "$0")"

echo "Preparando contexto de build para Docker..."

# --- Lógica para preparar el directorio ./ansible ---
if [[ -d ./ansible ]]; then
  echo "Eliminando directorio ./ansible local existente..."
  rm -rf ./ansible
fi

if [[ -d ~/ansible ]]; then
  echo "Copiando directorio ansible desde $HOME/ansible a ./ansible..."
  cp -rf ~/ansible ./ansible
elif [[ -d ~/.dotfiles/ansible ]]; then
  echo "Copiando directorio ansible desde ~/.dotfiles/ansible a ./ansible..."
  cp -rf ~/.dotfiles/ansible ./ansible
else
  echo "ADVERTENCIA: No se encontró un directorio fuente para ./ansible."
  # Considera crear una estructura mínima si tus playbooks dependen de ella
  # mkdir -p ./ansible/files ./ansible/tasks ./ansible/roles etc.
fi

# --- Lógica para preparar el directorio ./.config ---
if [[ -d ./.config ]]; then
  echo "Eliminando directorio ./.config local existente..."
  rm -rf ./.config
fi
mkdir -p ./.config # Crear el directorio .config en el contexto de build

if [[ -d ~/.config/nvim ]]; then
  echo "Copiando .config/nvim desde $HOME/.config/nvim a ./.config/nvim..."
  cp -rf ~/.config/nvim ./.config/nvim
elif [[ -d ~/.dotfiles/.config/nvim ]]; then
  echo "Copiando .config/nvim desde ~/.dotfiles/.config/nvim a ./.config/nvim..."
  cp -rf ~/.dotfiles/.config/nvim ./.config/nvim
else
  echo "ADVERTENCIA: No se encontró fuente para la configuración de Neovim."
fi

if [[ -d ~/.config/fish ]]; then
  echo "Copiando .config/fish desde $HOME/.config/fish a ./.config/fish..."
  cp -rf ~/.config/fish ./.config/fish
elif [[ -d ~/.dotfiles/.config/fish ]]; then
  echo "Copiando .config/fish desde ~/.dotfiles/.config/fish a ./.config/fish..."
  cp -rf ~/.dotfiles/.config/fish ./.config/fish
else
  echo "ADVERTENCIA: No se encontró fuente para la configuración de Fish."
fi

# Verificar si existe el Dockerfile
if [[ ! -f ./Dockerfile ]]; then
   echo "ERROR: No se encontró el Dockerfile en el directorio actual"
   exit 1
fi

IMAGE_NAME="ubuntu-development-environment" # Nombre de tu imagen

# --- AÑADIR ESTA SECCIÓN PARA CONSTRUIR LA IMAGEN ---
echo "Construyendo imagen Docker preconfigurada ($IMAGE_NAME)..."
# Puedes añadir --no-cache aquí si quieres forzar una reconstrucción completa sin usar la caché de Docker
# docker build --no-cache . -f Dockerfile -t $IMAGE_NAME
docker build . -f Dockerfile -t $IMAGE_NAME

# Verificar si el build fue exitoso antes de intentar ejecutar
if [ $? -ne 0 ]; then
    echo "ERROR: El build de Docker falló. No se ejecutará el contenedor."
    exit 1
fi
# --- FIN DE LA SECCIÓN AÑADIDA ---


# Ruta en tu máquina anfitriona macOS para persistir datos
DISK_DIR="/Users/ivanlynch/workspaces/ubuntu/disk" # Ajusta a tu nombre de usuario y ruta deseada
# Ruta DENTRO del contenedor
CONTAINER_USER_HOME="/home/ivanlynch" # Debe coincidir con USER_HOME en el Dockerfile

# Crear el directorio persistente en el host si no existe
mkdir -p "${DISK_DIR}"

echo "Ejecutando contenedor Docker preconfigurado con home persistente..."
docker run --rm -it \
    -v "${DISK_DIR}:${CONTAINER_USER_HOME}" \
    $IMAGE_NAME
