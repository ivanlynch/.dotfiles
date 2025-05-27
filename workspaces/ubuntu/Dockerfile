# Dockerfile actualizado
ARG TARGETPLATFORM

FROM --platform=$BUILDPLATFORM ubuntu:latest

# --- Nuevos argumentos para UID/GID ---
ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_NAME=ivanlynch

# --- Variables de entorno ---
ENV USER_HOME=/home/${USER_NAME}
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias (sin cambios)
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    git \
    curl \
    sudo \
    cmake \
    gettext \
    gpg \
    python3 \
    python3-pip \
    locales \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install ansible --break-system-packages

# Configurar locale
RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

# --- Crear usuario con UID/GID específicos ---
RUN groupadd sudo || true \
    && (groupadd -g $USER_GID $USER_NAME || true) \
    && useradd -m -u $USER_UID -g $USER_GID -G sudo -s /bin/bash $USER_NAME \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME

WORKDIR $USER_HOME

# Copiar archivos de configuración
COPY .config/fish $USER_HOME/.config/fish/
COPY .config/nvim $USER_HOME/.config/nvim/
COPY ansible $USER_HOME/ansible/
COPY bootstrap.yml $USER_HOME/

# --- Asegurar permisos correctos ---
RUN chown -R $USER_UID:$USER_GID $USER_HOME

# Ejecutar Ansible
RUN ansible-playbook -i localhost, -c local bootstrap.yml \
    -e "user_name=${USER_NAME}" \
    -e "user_home=${USER_HOME}"

USER $USER_NAME
CMD ["/usr/bin/fish"]
