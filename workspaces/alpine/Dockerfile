FROM alpine:latest

ARG USER=ivanlynch

# Actualizar el SO
RUN apk update

# Instalar dependencias básicas
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
    linux-headers

# Instalar herramientas de terminal
RUN apk add --no-cache \
    neovim \
    git \
    fish \
    fzf \
    zoxide \
    bat \
    eza \
    starship \
    nvm

# Crear un usuario no-root
RUN adduser -s /usr/bin/fish -D $USER
ENV HOME=/home/$USER

# Configurar entorno de desarrollo
COPY .config/fish /home/$USER/.config/fish
COPY .config/nvim /home/$USER/.config/nvim

# Actualizar e instalar dependencias de Neovim
RUN nvim --headless "+Lazy! sync" +qa

# Instalar NodeJS Lts
RUN nvm install --lts

# Script de entrada para manejar permisos
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

# Directorio de trabajo por defecto para proyectos
WORKDIR /workspace

# Entrypoint por defecto (puede ser sobrescrito)
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD []
