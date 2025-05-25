# Definir argumento de construcción para la plataforma
ARG TARGETPLATFORM
FROM --platform=$BUILDPLATFORM ubuntu:latest

ENV USER_NAME=ivanlynch

RUN add-apt-repository ppa:fish-shell/release-4

# Actualizar el sistema e instalar paquetes necesarios
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    zsh \
    sudo \
    ansible \
    cmake \
    gettext \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario y configurar permisos sudo
RUN useradd -m -G sudo -s /bin/zsh $USER_NAME && \
    echo "$USER_NAME:$USER_NAME" | chpasswd && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME

WORKDIR /home/$USER_NAME
USER $USER_NAME

COPY . .

CMD ["fish"]
