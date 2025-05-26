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
fi

# --- Lógica para preparar el directorio ./.config ---
# Esto es para que los archivos de config (nvim, fish) estén disponibles en el contexto de build
# y puedan ser COPIADOS a la imagen y luego usados por Ansible o por el usuario.
if [[ -d ./.config ]]; then
  echo "Eliminando directorio ./.config local existente..."
  rm -rf ./.config
fi

mkdir -p ./.config # Crear el directorio .config en el contexto de build

# Copiar configuración de Neovim al contexto de build
if [[ -d ~/.config/nvim ]]; then
  echo "Copiando .config/nvim desde $HOME/.config/nvim a ./.config/nvim..."
  cp -rf ~/.config/nvim ./.config/nvim
elif [[ -d ~/.dotfiles/.config/nvim ]]; then
  echo "Copiando .config/nvim desde ~/.dotfiles/.config/nvim a ./.config/nvim..."
  cp -rf ~/.dotfiles/.config/nvim ./.config/nvim
fi

# Copiar configuración de Fish al contexto de build
# Esto es si quieres que Ansible COPIE esta config al home del usuario DENTRO del contenedor.
# Nota: El ansible/files/config.fish es el que custom_fish_config_src apuntará normalmente.
# Decide cuál es tu fuente de verdad. Si es el config.fish en tu anfitrión:
if [[ -d ~/.config/fish ]]; then
  echo "Copiando .config/fish desde $HOME/.config/fish a ./.config/fish..."
  cp -rf ~/.config/fish ./.config/fish
elif [[ -d ~/.dotfiles/.config/fish ]]; then
  echo "Copiando .config/fish desde ~/.dotfiles/.config/fish a ./.config/fish..."
  cp -rf ~/.dotfiles/.config/fish ./.config/fish
fi

# Verificar si existe el Dockerfile
if [[ ! -f ./Dockerfile ]]; then
   echo "ERROR: No se encontró el Dockerfile en el directorio actual"
   exit 1
fi

IMAGE_NAME="ubuntu-development-environment" # O como la hayas llamado
# Ruta en tu máquina anfitriona macOS
DISK_DIR="/Users/ivanlynch/workspaces/ubuntu/disk" # Ajusta a tu nombre de usuario y ruta
# Ruta DENTRO del contenedor
CONTAINER_USER_HOME="/home/ivanlynch" # Debe coincidir con USER_HOME en el Dockerfile

echo "Ejecutando contenedor Docker preconfigurado con home persistente..."
docker run --rm -it \
    -v "${DISK_DIR}:${CONTAINER_USER_HOME}" \
    $IMAGE_NAME