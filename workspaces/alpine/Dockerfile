FROM alpine:latest

# Configuración del usuario
# Definir el usuario y el directorio de trabajo
ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
ENV HOME=/home/$USER_NAME
WORKDIR $HOME

# Crear un usuario no-root
RUN adduser -s /usr/bin/fish -D $USER_NAME -u $USER_ID -G users -g "User $USER_NAME"

# Establecer PATH después de HOME
ENV PATH="${HOME}/.cargo/bin:${PATH}"

# Actualizar el SO e instalar todas las dependencias en una sola capa para optimizar cache
RUN apk update && apk add --no-cache
# Dependencias básicas
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
    python3 \
    py3-isort \
    black \
    nodejs-current \
    xclip \
    lua5.1 \
    lua5.1-dev \
    luarocks
# Herramientas de terminal
git \
    fish \
    fzf \
    zoxide \
    bat \
    eza \
    starship \
    npm
# Neovim
neovim \
    neovim-doc
# Runtimes
rust \
    cargo &&
    rm -rf /var/cache/apk/*

# Instalar dependencias de desarrollo globales en una sola capa
RUN npm install -g \
    vscode-langservers-extracted \
    typescript-language-server \
    typescript \
    vscode-markdown-languageserver \
    prettier \
    @fsouza/prettierd &&
    npm cache clean --force &&
    cargo install stylua rustfmt &&
    rm -rf /usr/local/cargo/registry

# Configurar entorno de desarrollo - hash para invalidar cache cuando configs cambien
ARG CONFIG_HASH
ARG CACHEBUST=1

COPY .config/fish $HOME/.config/fish
COPY .config/nvim $HOME/.config/nvim

# Cambiar ownership antes de ejecutar como usuario
RUN chown -R $USER_NAME:users $HOME/.config

# Actualizar e instalar dependencias de Neovim como usuario
USER $USER_NAME
RUN nvim --headless "+Lazy! sync" +qa || true
USER root

# Script de entrada para manejar permisos
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

# Entrypoint por defecto (puede ser sobrescrito)
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD []
