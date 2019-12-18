FROM debian:stretch
ARG DOCKER_GROUP_ID

# setup debian
ENV DEBIAN_URL "http://ftp.us.debian.org/debian"
RUN echo "deb $DEBIAN_URL testing main contrib non-free" >> /etc/apt/sources.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    automake \
    build-essential \
    bzip2 \
    ca-certificates \
    cmake \
    g++ \
    gettext \
    git \
    git-lfs \
    jq \
    libbz2-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libtool-bin \
    libxml2 \
    libxml2-dev  \
    locales \
    lua5.3 \
    mosh \
    netcat \
    openssl \
    pkg-config \
    postgresql-client \
    rsync \
    silversearcher-ag \
    sqlite3 \
    tmux \
    tree \
    unzip \
    vifm \
    xfonts-utils \
    zlib1g-dev \
    zsh \
  && apt-get clean all

# setup local
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# setup neovim
RUN cd /usr/src \
  && git clone --depth 1 https://github.com/neovim/neovim.git \
  && cd neovim \
  && make CMAKE_BUILD_TYPE=RelWithDebInfo \
    CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local" \
  && make install \
  && rm -r /usr/src/neovim

# setup go
ENV GO_VERSION "1.13.4"
RUN curl -sfLo /tmp/golang.tgz --create-dirs \
    "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" \
  && tar -C /usr/local -xzf /tmp/golang.tgz \
  && rm /tmp/golang.tgz

# setup docker
ENV DOCKERVERSION "19.03.5"
RUN curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz" | \
  tar zxvf - --strip 1 -C /usr/bin docker/docker

# setup user
ENV HOME /home/wamberg
RUN groupdel users \
  && groupadd -r wamberg \
  && groupadd -g "${DOCKER_GROUP_ID}" docker \
  && useradd \
    --create-home --home-dir $HOME --gid wamberg --groups docker \
    --shell /bin/zsh \
    wamberg
USER wamberg
WORKDIR $HOME

# setup pyenv
ENV PYTHON_VERSION "3.8.0"
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH "$PYENV_ROOT/shims:$PYENV_ROOT/bin:$HOME/.local/bin:${PATH}"
RUN git clone --depth 1 git://github.com/yyuu/pyenv.git .pyenv
RUN pyenv install $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION
RUN pyenv rehash

# setup dev dependencies
RUN pip install --user \
    awscli \
    black \
    bumpversion \
    docker-compose \
    flake8 \
    ipython \
    isort \
    neovim \
    pipenv \
    tmuxp \
    tox \
  && git config --global user.email "wamberg@accelerate.delivery" \
  && git config --global user.name "Bill Amberg" \
  && git config --global pager.branch false \
  && mkdir .zfunctions
RUN git clone --depth 1 git://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
RUN git clone --depth 1 https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
COPY --chown=wamberg .zsh/.zshrc ./
COPY --chown=wamberg .zsh/pure/pure.zsh ./.zfunctions/prompt_pure_setup
COPY --chown=wamberg .zsh/pure/async.zsh ./.zfunctions/async
COPY --chown=wamberg .config ./.config
COPY --chown=wamberg .tmux.conf ./
COPY --chown=wamberg .tmuxp ./.tmuxp
COPY --chown=wamberg .gitignore_global ./
COPY --chown=wamberg .editorconfig ./

RUN mkdir -p .config/tmux/plugins \
  && if [ -d ~/.config/tmux/plugins/tpm ]; then rm -Rf ~/.config/tmux/plugins/tpm; fi \
  && git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm \
  && ~/.config/tmux/plugins/tpm/bin/install_plugins

# setup nvm
ENV NODE_VERSION "12.13.1"
RUN /bin/zsh -c "source ~/.zshrc && nvm install ${NODE_VERSION}"

# setup dev configuration
RUN curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  && nvim --headless +PlugInstall +qall > /dev/null \
  && /bin/zsh -c "source ~/.zshrc && cd ~/.config/coc/extensions && npm install --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod" \
  && git config --global core.excludesfile ~/.gitignore_global \
  && mkdir dev
RUN /bin/zsh -c "source ~/.zshrc && npm install --global yarn"

CMD ["zsh"]
