FROM alpine:latest

ARG USER=ivanlynch

# Instalar paquetes básicos
RUN apk update && \
    apk add --no-cache \
    neovim git git-perl \
    fish openssh-client \
    curl less \
    fzf zoxide \
    bat ripgrep starship \
    tmux bash ncurses \
    docker py3-pip \
    su-exec shadow \
    gcc g++ make libc-dev \
    build-base

# Crear un usuario no-root
RUN adduser -s /usr/bin/fish -D $USER
ENV HOME=/home/$USER

# Configurar entorno de desarrollo
COPY .config/fish /home/$USER/.config/fish
COPY .config/nvim /home/$USER/.config/nvim

# Script de entrada para manejar permisos
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

# Directorio de trabajo por defecto para proyectos
WORKDIR /workspace

# Entrypoint por defecto (puede ser sobrescrito)
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD []

