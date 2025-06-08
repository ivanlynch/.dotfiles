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
    linux-headers \
    python3 \
    py3-isort \
    black \
    nodejs-current \
    xclip \
    lua5.1 \
    lua5.1-dev \
    luarocks

# Instalar herramientas de terminal
RUN apk add --no-cache \
    git \
    fish \
    fzf \
    zoxide \
    bat \
    eza \
    starship \
    npm

# Instalar Neovim
RUN apk add --no-cache \
    neovim \
    neovim-doc

# Instalar Runtimes
RUN apk add --no-cache rust cargo

# Configurar entorno de desarrollo
ARG CACHEBUST=1

COPY .config/fish $HOME/.config/fish
COPY .config/nvim $HOME/.config/nvim

# Actualizar e instalar dependencias de Neovim
RUN nvim --headless "+Lazy! sync" +qa

# LSPs
RUN npm install -g vscode-langservers-extracted
RUN npm install -g typescript-language-server typescipt
RUN npm install -g vscode-markdown-languageserver

# Formatters
RUN npm install -g prettier @fsouza/prettierd
RUN cargo install stylua rustfmt

# Script de entrada para manejar permisos
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

# Entrypoint por defecto (puede ser sobrescrito)
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD []
