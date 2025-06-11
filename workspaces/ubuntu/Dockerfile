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
    fish && rm -rf /var/lib/apt/lists/*

RUN pip3 install ansible --break-system-packages

# --- Configurar locale ---
RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"

# --- Manejo de usuario y grupos ---
RUN set -eux
if id -u ubuntu >/dev/null 2>&1; then
    userdel -r ubuntu 2>/dev/null || true
fi
existing_group=$(getent group "$USER_GID" | cut -d: -f1)
if [ -z "$existing_group" ]; then
    groupadd -g "$USER_GID" "$USER_NAME"
else
    groupmod -n "$USER_NAME" "$existing_group"
fi
useradd -m -u "$USER_UID" -g "$USER_GID" -s /usr/bin/fish "$USER_NAME"
mkdir -p /home/$USER_NAME/.config/fish/{completions,conf.d,functions} &&
    chown -R $USER_NAME:$USER_NAME /home/$USER_NAME
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/$USER_NAME
chmod 0440 /etc/sudoers.d/$USER_NAME

USER $USER_NAME
WORKDIR /home/$USER_NAME

# --- Copiar configuraciones con permisos correctos ---
COPY --chown=$USER_NAME:$USER_NAME .config/fish /home/$USER_NAME/.config/fish/
COPY --chown=$USER_NAME:$USER_NAME .config/nvim /home/$USER_NAME/.config/nvim/
COPY --chown=$USER_NAME:$USER_NAME ansible /home/$USER_NAME/ansible/
COPY --chown=$USER_NAME:$USER_NAME bootstrap.yml /home/$USER_NAME/

# --- Ejecutar Ansible ---
RUN ansible-playbook -i localhost, -c local bootstrap.yml \
    -e "user_name=$USER_NAME" \
    -e "user_home=/home/$USER_NAME"

# --- Configurar Git safe directories para plugins de Neovim ---
RUN git config --global --add safe.directory "/home/$USER_NAME/.local/share/nvim/lazy/lazy.nvim" &&
    git config --global --add safe.directory "/home/$USER_NAME/.local/share/nvim/lazy/conform.nvim" &&
    git config --global --add safe.directory "/home/$USER_NAME/.local/share/nvim/lazy/fzf-lua" &&
    git config --global --add safe.directory "/home/$USER_NAME/.local/share/nvim/lazy/nvim-treesitter" &&
    git config --global --add safe.directory "/home/$USER_NAME/.local/share/nvim/lazy/nvim-web-devicons" &&
    git config --global --add safe.directory "/home/$USER_NAME/.local/share/nvim/lazy/*" &&
    git config --global --add safe.directory "/home/$USER_NAME/workspace" &&
    git config --global --add safe.directory "/home/$USER_NAME/workspace/*" &&
    git config --global --add safe.directory "/home/$USER_NAME/workspaces" &&
    git config --global --add safe.directory "/home/$USER_NAME/workspaces/*" &&
    git config --global --add safe.directory "/home/$USER_NAME/.dotfiles" &&
    git config --global --add safe.directory "*"

CMD ["/usr/bin/fish"]
