# Dockerfile
ARG TARGETPLATFORM
FROM --platform=$BUILDPLATFORM ubuntu:latest

ENV USER_NAME=ivanlynch
ENV USER_HOME=/home/${USER_NAME}
# Para evitar prompts durante apt-get install
ENV DEBIAN_FRONTEND=noninteractive

# Instalar software-properties-common, sudo, y otras dependencias básicas
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

# Instalar Ansible vía pip
RUN pip3 install ansible --break-system-packages

# Configurar locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Crear usuario. Se crea con /bin/bash. Ansible cambiará el shell a fish después.
# No especificamos UID/GID para que useradd elija el siguiente disponible.
RUN groupadd sudo || true # Asegurar que el grupo sudo exista
RUN useradd -m -G sudo -s /bin/bash $USER_NAME \
    && echo "$USER_NAME:$USER_NAME" | chpasswd \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME

# Directorio de trabajo para la configuración con Ansible
WORKDIR /app

# Copiar todos los archivos del contexto de build
COPY . .

# Ejecutar Ansible playbook para configurar el entorno como root
RUN ansible-playbook -i localhost, -c local bootstrap.yml \
    -e "target_fish_user=${USER_NAME}" \
    -e "target_fish_user_home=${USER_HOME}" \
    -e "custom_fish_config_src=/app/.config/fish/config.fish" \
    -e "neovim_config_src_dir=/app/.config/nvim" \
    -e "fish_local_config_src_dir=/app/.config/fish"

RUN echo ">>> Contenido de /home/${USER_NAME}/.config/fish/config.fish después de Ansible:" \
    && cat "${USER_HOME}/.config/fish/config.fish" || echo ">>> Archivo config.fish no encontrado en el home del usuario."
RUN echo ">>> Contenido de /home/${USER_NAME}/.config/fish/conf.d/00_local_bin_path.fish después de Ansible:" \
    && cat "${USER_HOME}/.config/fish/conf.d/00_local_bin_path.fish" || echo ">>> Archivo 00_local_bin_path.fish no encontrado."

# Cambiar al usuario no root
USER $USER_NAME
WORKDIR ${USER_HOME}

CMD ["/usr/bin/fish"]
