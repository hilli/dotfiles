FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Install base dependencies needed for chezmoi and the dotfiles
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    zsh \
    locales \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Generate locales needed by the dotfiles
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install the latest chezmoi binary
RUN sh -c "$(curl -fsLS chezmoi.io/get)" -- -b /usr/local/bin

# Create a test user with sudo access (no password)
RUN useradd -m -s /bin/zsh testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# The chezmoi source directory will be mounted at runtime
# Default entrypoint is zsh for interactive use
CMD ["/bin/zsh", "-l"]
