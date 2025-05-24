# Definir argumento de construcción para la plataforma
ARG TARGETPLATFORM
FROM --platform=${TARGETPLATFORM} archlinux/archlinux:latest

ENV USER_NAME=ivanlynch

# Actualizar el sistema e instalar paquetes necesarios
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git curl zsh sudo ansible cmake gettext

# Crear usuario y configurar permisos sudo
RUN useradd -m -G wheel -s /bin/zsh $USER_NAME && \
    echo "$USER_NAME:$USER_NAME" | chpasswd && \
    sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^#//' /etc/sudoers

WORKDIR /home/$USER_NAME
USER $USER_NAME

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY . .

CMD ["zsh"]
