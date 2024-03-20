FROM ubuntu:jammy

ARG USERNAME=dev
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y wget git zsh; \
    useradd --create-home --user-group --no-log-init "$USERNAME"; \
    mkdir -p "/home/$USERNAME/dotfiles"; \
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
USER "$USERNAME"

CMD ["sleep", "infinity"]
