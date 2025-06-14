FROM alpine:latest

# Configuración del usuario
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
RUN apk update && apk add --no-cache openssh-client curl less ripgrep ncurses su-exec shadow gcc g++ make cmake musl-dev linux-headers readline-dev ncurses-dev python3 py3-pip py3-isort black nodejs-current xclip lua5.1 lua5.1-dev luarocks git fish fzf zoxide bat eza starship npm neovim neovim-doc rust cargo findutils viu chafa && rm -rf /var/cache/apk/*

# Instalar dependencias de desarrollo globales
RUN npm install -g vscode-langservers-extracted typescript-language-server typescript vscode-markdown-languageserver prettier @fsouza/prettierd && npm cache clean --force
RUN cargo install stylua rustfmt && rm -rf /usr/local/cargo/registry

# Configurar entorno de desarrollo - hash para invalidar cache cuando configs cambien
ARG CONFIG_HASH
ARG CACHEBUST=1

# Crear directorios de configuración antes de copiar
RUN mkdir -p $HOME/.config

COPY .config/fish $HOME/.config/fish
COPY .config/nvim $HOME/.config/nvim

# Cambiar ownership antes de ejecutar como usuario
RUN chown -R $USER_NAME:users $HOME/.config

# Configurar luarocks para Neovim como usuario (después de copiar configs)
USER $USER_NAME
RUN pip3 install --user --break-system-packages hererocks
RUN mkdir -p ~/.local/share/nvim/lazy-rocks && cd ~/.local/share/nvim/lazy-rocks && ~/.local/bin/hererocks hererocks --lua=5.1 --luarocks=latest
RUN echo 'set -gx PATH "$HOME/.local/share/nvim/lazy-rocks/hererocks/bin" "$HOME/.local/bin" $PATH' >>~/.config/fish/config.fish

# Actualizar e instalar dependencias de Neovim como usuario
RUN nvim --headless "+Lazy! sync" +qa || true
USER root

# Asegurar ownership correcto después de todas las configuraciones
RUN chown -R $USER_NAME:users $HOME/.config $HOME/.local

# Actualizar PATH para incluir hererocks
ENV PATH="$HOME/.local/share/nvim/lazy-rocks/hererocks/bin:$HOME/.local/bin:$PATH"

# Script de entrada para manejar permisos
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

# Entrypoint por defecto (puede ser sobrescrito)
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD []
