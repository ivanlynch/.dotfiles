# syntax=docker/dockerfile:1.4
ARG TARGETPLATFORM

FROM --platform=$BUILDPLATFORM ubuntu:latest

# --- Variables de entorno ---
ENV DEBIAN_FRONTEND=noninteractive

ARG USER_UID
ARG USER_GID
ARG USER_NAME

# --- Instalar dependencias ---
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

# --- Configurar locale ---
RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

# --- Eliminar usuario ubuntu si existe y crear usuario con UID/GID específicos ---
RUN set -eux; \
    if id -u ubuntu >/dev/null 2>&1; then \
        userdel -r ubuntu 2>/dev/null || true; \
    fi; \
    if getent group "$USER_GID" >/dev/null; then \
        EXISTING_GROUP=$(getent group "$USER_GID" | cut -d: -f1); \
        echo "Reutilizando grupo existente: $EXISTING_GROUP (GID: $USER_GID)"; \
    else \
        groupadd -g "$USER_GID" "$USER_NAME"; \
        EXISTING_GROUP="$USER_NAME"; \
        echo "Creado nuevo grupo: $USER_NAME (GID: $USER_GID)"; \
    fi; \
    if id -u "$USER_NAME" >/dev/null 2>&1; then \
        usermod -u "$USER_UID" -g "$USER_GID" "$USER_NAME"; \
        echo "Modificado usuario existente: $USER_NAME (UID: $USER_UID, GID: $USER_GID)"; \
    else \
        useradd -m -u "$USER_UID" -g "$USER_GID" -s /bin/bash "$USER_NAME"; \
        echo "Creado nuevo usuario: $USER_NAME (UID: $USER_UID, GID: $USER_GID)"; \
    fi; \
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME; \
    chmod 0440 /etc/sudoers.d/$USER_NAME

USER $USER_NAME
WORKDIR /home/$USER_NAME

# --- Copiar archivos de configuración ---
COPY --chown=$USER_NAME:$USER_NAME .config/fish /home/$USER_NAME/.config/
COPY --chown=$USER_NAME:$USER_NAME .config/nvim /home/$USER_NAME/.config/
COPY --chown=$USER_NAME:$USER_NAME ansible /home/$USER_NAME/ansible/
COPY --chown=$USER_NAME:$USER_NAME bootstrap.yml /home/$USER_NAME/

# --- Ejecutar Ansible ---
RUN ansible-playbook -i localhost, -c local bootstrap.yml \
    -e "user_name=$USER_NAME" \
    -e "user_home=/home/$USER_NAME"

CMD ["/usr/bin/fish"]