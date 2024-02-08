FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV USER_NAME=ivanlynch

RUN useradd -m $USER_NAME && \
    echo "$USER_NAME:$USER_NAME" | chpasswd && \
    adduser $USER_NAME sudo

RUN apt update && \
    apt install -y software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt update && \
    apt upgrade -y && \
    apt install -y curl git build-essential cmake gettext zsh sudo ansible && \
    apt clean autoclean && \
    apt autoremove --yes


WORKDIR /home/$USER_NAME
USER $USER_NAME

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY . .

CMD ["zsh"]
