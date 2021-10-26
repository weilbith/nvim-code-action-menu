FROM archlinux:base-devel-20211024.0.37588

RUN pacman --sync --sysupgrade --refresh --noconfirm
RUN pacman --sync --noconfirm git
RUN useradd --create-home circleci
RUN echo 'circleci ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers

USER circleci

RUN git clone https://aur.archlinux.org/pikaur.git /tmp/pikaur
RUN cd /tmp/pikaur && makepkg --syncdeps --install --noconfirm && cd
RUN pikaur --sync --noconfirm python-pre-commit luacheck stylua-bin

WORKDIR /home/circleci
