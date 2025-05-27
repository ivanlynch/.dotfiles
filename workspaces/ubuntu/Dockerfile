ARG TARGETPLATFORM
FROM --platform=$BUILDPLATFORM ubuntu:latest

# --- Variables de entorno ---
ENV DEBIAN_FRONTEND=noninteractive
ARG USER_UID=1000  # Debe coincidir con tu UID en el host
ARG USER_GID=1000  # Debe coincidir con tu GID en el host

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

# --- Usar usuario existente (ubuntu) y ajustar UID/GID ---
RUN usermod -u $USER_UID ubuntu \
    && groupmod -g $USER_GID ubuntu \
    && chown -R $USER_UID:$USER_GID /home/ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# --- Copiar archivos de configuración ---
COPY --chown=ubuntu:ubuntu .config/fish /home/ubuntu/.config/fish/
COPY --chown=ubuntu:ubuntu .config/nvim /home/ubuntu/.config/nvim/
COPY --chown=ubuntu:ubuntu ansible /home/ubuntu/ansible/
COPY --chown=ubuntu:ubuntu bootstrap.yml /home/ubuntu/

# --- Ejecutar Ansible ---
RUN ansible-playbook -i localhost, -c local bootstrap.yml \
    -e "user_name=ubuntu" \
    -e "user_home=/home/ubuntu"

CMD ["/usr/bin/fish"]