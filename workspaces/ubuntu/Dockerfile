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

# Ejecutar Ansible playbook SOLO PARA INSTALAR DEPENDENCIAS Y CONFIGURAR SHELL
# El playbook 'bootstrap.yml' y las tareas importadas
# NO deberían intentar copiar o modificar config.fish ni conf.d directamente.
# Solo deben instalar paquetes y asegurar que fish sea el shell por defecto.
RUN ansible-playbook -i localhost, -c local bootstrap.yml \
    -e "target_fish_user=${USER_NAME}" \
    -e "target_fish_user_home=${USER_HOME}"
    # No pasar custom_fish_config_src si Ansible no va a copiar config.fish

# --- COPIAR LA CONFIGURACIÓN DEL USUARIO DESDE EL HOST Y ARREGLAR PERMISOS ---
# Asegurar que el directorio .config del usuario exista
RUN mkdir -p ${USER_HOME}/.config && chown $USER_NAME:$USER_NAME ${USER_HOME}/.config

# Copiar el .config (que vino del host y está en /app/.config) al home del usuario.
# Esto se hace como root.
RUN cp -a /app/.config/. ${USER_HOME}/.config/
# cp -a (archive) preserva permisos, enlaces, etc., pero la propiedad será root
# si la fuente es propiedad de root.

# ¡CRUCIAL! Cambiar la propiedad de todo en ${USER_HOME}/.config al usuario.
RUN chown -R $USER_NAME:$USER_NAME ${USER_HOME}/.config

# Debug: Verificar permisos después de la copia y chown (ejecutado como root)
RUN echo ">>> Permisos en ${USER_HOME}/.config después de COPY y CHOWN:" && ls -la "${USER_HOME}/.config" || true
RUN echo ">>> Permisos en ${USER_HOME}/.config/fish después de COPY y CHOWN:" && ls -la "${USER_HOME}/.config/fish" || true

# Cambiar al usuario no root
USER $USER_NAME
WORKDIR ${USER_HOME}

CMD ["/usr/bin/fish"]
