FROM base/archlinux:latest
MAINTAINER Gomasy <nyan@gomasy.jp>

# Update and install packages
RUN pacman -Sy --noconfirm archlinux-keyring
RUN pacman -Syu --noconfirm
RUN pacman-db-upgrade
RUN pacman -Sgq base | sed -e ':loop; N; $!b loop; s/\n/ /g' | sed -e 's/linux //' | xargs pacman -S --noconfirm --needed base-devel yajl

# Install yaourt
RUN useradd -m temp
RUN su -l temp -c "cd /home/temp && curl -s https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz | tar xvfz -"
RUN su -l temp -c "cd /home/temp/package-query && makepkg"
RUN pacman -U --noconfirm /home/temp/package-query/*.tar.xz
RUN su -l temp -c "cd /home/temp && curl -s https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz | tar xvfz -"
RUN su -l temp -c "cd /home/temp/yaourt && makepkg"
RUN pacman -U --noconfirm /home/temp/yaourt/*.tar.xz
RUN userdel -r temp

# Create user
RUN useradd -m gomasy
RUN gpasswd -a gomasy wheel
RUN sed -ie "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers

# Install tor
RUN su -l gomasy -c "yaourt -S chromium tor ttf-koruri --noconfirm"

# Delete unnecessary files
RUN pacman -Scc --noconfirm
RUN find / -name "*.pacnew" | xargs rm

# Add run script
ADD run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
