# Dockerfile
ARG TARGETPLATFORM
FROM --platform=$BUILDPLATFORM ubuntu:latest

ENV USER_NAME=ivanlynch
ENV USER_HOME=/home/${USER_NAME}
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias base y Ansible
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

# Crear usuario con bash como shell inicial y permisos sudo
RUN groupadd sudo || true
RUN useradd -m -G sudo -s /bin/bash $USER_NAME \
    && echo "$USER_NAME:$USER_NAME" | chpasswd \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME

# Directorio de trabajo para Ansible y copia inicial de artefactos
WORKDIR /app
COPY . .

# --- Paso 1 de Configuración del Usuario (Hecho por Docker como root) ---
# Copiar el .config COMPLETO del anfitrión (que está en /app/.config) al home del usuario
# Y establecer los permisos correctos.
RUN mkdir -p ${USER_HOME}/.config && chown $USER_NAME:$USER_NAME ${USER_HOME}/.config
RUN cp -a /app/.config/. ${USER_HOME}/.config/
RUN chown -R $USER_NAME:$USER_NAME ${USER_HOME}/.config

# --- Paso 2: Ejecutar Ansible para instalar herramientas y configurar el shell ---
# Ansible ahora opera sobre un ~/.config/fish/ ya poblado por el paso anterior.
# El playbook de Ansible NO debería volver a copiar config.fish,
# SÍ debería crear conf.d/00_local_bin_path.fish
# SÍ debería ejecutar ~/.fzf/install --all (ahora que config.fish ya existe)
RUN ansible-playbook -i localhost, -c local bootstrap.yml \
    -e "user_name=${USER_NAME}" \
    -e "user_home=${USER_HOME}"

# Debug final (opcional)
RUN echo ">>> Permisos en ${USER_HOME}/.config/fish después de Ansible:" && ls -la "${USER_HOME}/.config/fish" || true
RUN echo ">>> Contenido de ${USER_HOME}/.config/fish/conf.d/ después de Ansible:" && ls -la "${USER_HOME}/.config/fish/conf.d/" || true
RUN echo ">>> Contenido de ${USER_HOME}/.config/fish/functions/ después de Ansible:" && ls -la "${USER_HOME}/.config/fish/functions/" || true


USER $USER_NAME
WORKDIR ${USER_HOME}
CMD ["/usr/bin/fish"]