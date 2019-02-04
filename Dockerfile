FROM debian:stretch

# setup debian
ENV DEBIAN_URL "http://ftp.us.debian.org/debian"
RUN echo "deb $DEBIAN_URL testing main contrib non-free" >> /etc/apt/sources.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    automake \
    bzip2 \
    cmake \
    g++ \
    gettext \
    git \
    libbz2-dev \
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libtool-bin \
    locales \
    lua5.3 \
    netcat \
    openssl \
    pkg-config \
    silversearcher-ag \
    sqlite3 \
    tmux \
    unzip \
    xclip \
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

# setup user
ENV HOME /home/wamberg
RUN groupdel users \
  && groupadd -r wamberg \
  && useradd \
    --create-home --home-dir $HOME -g wamberg \
    --shell /bin/zsh \
    wamberg
USER wamberg
WORKDIR $HOME

# setup pyenv
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH "$PYENV_ROOT/shims:$PYENV_ROOT/bin:$HOME/.local/bin:${PATH}"
RUN git clone --depth 1 git://github.com/yyuu/pyenv.git .pyenv
RUN pyenv install 3.7.2
RUN pyenv global 3.7.2
RUN pyenv rehash

# setup dev dependencies
RUN pip install --user \
  black \
  flake8 \
  isort \
  neovim \
  pre-commit \
  tmuxp \
  tox
RUN git clone --depth 1 git://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
RUN git clone --depth 1 https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
RUN git clone --depth 1 git://github.com/wamberg/dot_files.git \
  && mv dot_files/.zsh/.zshrc ./ \
  && mv dot_files/.config ./ \
  && mv dot_files/.tmux.conf ./ \
  && mv dot_files/.tmuxp ./ \
  && mv dot_files/.gitignore_global ./ \
  && rm -rf dot_files \
  && git config --global user.email "wamberg@accelerate.delivery" \
  && git config --global user.name "Bill Amberg"

# setup nvm
RUN /bin/zsh -c "source ~/.zshrc && nvm install lts/dubnium"

# setup dev configuration
RUN curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  && nvim --headless +'PlugInstall' +qall \
  && git config --global core.excludesfile ~/.gitignore_global \
  && mkdir src

CMD ["zsh"]
