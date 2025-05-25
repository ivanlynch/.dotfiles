#!/bin/bash

# Asegurarnos de estar en el directorio correcto
cd "$(dirname "$0")"

# Eliminar directorio ansible local si existe
if [[ -d ansible ]]; then
   echo "Eliminando directorio ansible existente..."
   rm -r ./ansible 
fi

if [[ -d .config ]]; then
   echo "Eliminando directorio .config existente"
   rm -r ./.config
fi

# Verificar si existe el directorio ansible en home y copiarlo
if [[ -d ~/ansible ]]; then
   echo "Copiando directorio ansible desde $HOME/ansible..."
   cp -r ~/ansible ansible
# Si no existe en home, verificar si existe en el repositorio dotfiles
elif [[ -d ~/.dotfiles/ansible ]]; then
   echo "Copiando directorio ansible desde el repositorio dotfiles..."
   cp -r ~/.dotfiles/ansible ansible
fi

pwd

# Verificar si existe configuracion de Neovim
if [[ -d ~/.config/nvim ]]; then
   echo "Copiando directorio .config/nvim desde $HOME/.config/nvim..."
   mkdir .config
   cp -r ~/.config/nvim .config/nvim
# Si no existe en home, verificar si existe en el repositorio dotfiles
elif [[ -d ~/.dotfiles/.config/nvim ]]; then
   echo "Copiando directorio .config/nvim desde el repositorio dotfiles..."
   mkdir .config
   cp -r ~/.dotfiles/.config/nvim .config/nvim
fi

# Verificar si existe configuracion de Neovim
if [[ -d ~/.config/fish ]]; then
   echo "Copiando directorio .config/fish desde $HOME/.config/fish..."
   cp -r ~/.config/fish .config/fish
# Si no existe en home, verificar si existe en el repositorio dotfiles
elif [[ -d ~/.dotfiles/.config/fish ]]; then
   echo "Copiando directorio .config/fish desde el repositorio dotfiles..."
   cp -r ~/.dotfiles/.config/fish .config/fish
fi

# Verificar si existe el Dockerfile
if [[ ! -f ./Dockerfile ]]; then
   echo "ERROR: No se encontró el Dockerfile en el directorio actual"
   exit 1
fi

echo "Construyendo y ejecutando contenedor Docker..."
docker build . -f Dockerfile -t clean && docker run --rm -it clean bash -c "ansible-playbook -vvvv -i localhost, -c local bootstrap.yml && exec fish"

