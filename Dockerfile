FROM base/archlinux:latest
LABEL maintainer="Gomasy <nyan@gomasy.jp>"

# Update and install packages
RUN pacman -Sy --noconfirm archlinux-keyring && \
    pacman -Syu --noconfirm && \
    pacman-db-upgrade && \
    pacman -Sgq base | sed -e ':loop; N; $!b loop; s/\n/ /g' | sed -e 's/linux //' | xargs pacman -S --noconfirm --needed base-devel yajl && \
    useradd -m temp && \
    su -l temp -c "cd /home/temp && curl -s https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz | tar xvfz -" && \
    su -l temp -c "cd /home/temp/package-query && makepkg" && \
    pacman -U --noconfirm /home/temp/package-query/*.tar.xz && \
    su -l temp -c "cd /home/temp && curl -s https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz | tar xvfz -" && \
    su -l temp -c "cd /home/temp/yaourt && makepkg" && \
    pacman -U --noconfirm /home/temp/yaourt/*.tar.xz && \
    userdel -r temp && \
    pacman -Scc --noconfirm

# Install tor
RUN useradd -m gomasy && \
    gpasswd -a gomasy wheel && \
    sed -ie "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers && \
    su -l gomasy -c "yaourt -S chromium tor ttf-koruri --noconfirm" && \
    pacman -Scc --noconfirm

# Add run script
ADD run.sh /run.sh

CMD [ "/run.sh" ]
