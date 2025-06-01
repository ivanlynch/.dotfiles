FROM alpine:latest

# Definir argumento de build para el usuario, con valor por defecto
ARG USER=ivanlynch

# Actualizar el SO
RUN apk update

# Instalar dependencias básicas incluyendo bash (requerido para NVM)
RUN apk add --no-cache \
    openssh-client \
    curl \
    less \
    ripgrep \
    ncurses \
    su-exec \
    shadow \
    gcc \
    g++ \
    make \
    cmake \
    musl-dev \
    linux-headers \
    bash \
    ca-certificates \
    openssl \
    coreutils \
    python3 \
    libgcc \
    grep \
    util-linux \
    binutils \
    findutils

# Instalar herramientas de terminal
RUN apk add --no-cache \
    neovim \
    git \
    fish \
    fzf \
    zoxide \
    bat \
    eza \
    starship

# Crear un usuario no-root usando el argumento de build
RUN adduser -s /usr/bin/fish -D $USER
ENV HOME=/home/$USER

# Instalar NVM
ENV NVM_DIR=/home/$USER/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Configurar variables de entorno para NVM
ENV PATH=$NVM_DIR/versions/node/v*/bin:$PATH

# Instalar la versión LTS más reciente de Node.js usando NVM
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install --lts && nvm use --lts && nvm alias default lts/*"

# Configurar entorno de desarrollo
COPY .config/fish /home/$USER/.config/fish
COPY .config/nvim /home/$USER/.config/nvim

# Cambiar ownership de los archivos de configuración
RUN chown -R $USER:$USER /home/$USER/.config && \
    chown -R $USER:$USER $NVM_DIR

# Actualizar e instalar dependencias de Neovim
RUN nvim --headless "+Lazy! sync" +qa

# Script de entrada para manejar permisos
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

# Directorio de trabajo por defecto para proyectos
WORKDIR /workspace

# Entrypoint por defecto (puede ser sobrescrito)
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD []
