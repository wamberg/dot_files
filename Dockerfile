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
    libffi-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libtool-bin \
    locales \
    lua5.3 \
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
    --create-home --home-dir $HOME \
    --system -g wamberg \
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
RUN pip install --user neovim tmuxp

# setup dev configuration
RUN git clone --depth 1 git://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
RUN curl -sfLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN git clone --depth 1 git://github.com/wamberg/dot_files.git \
  && mv dot_files/.zsh/.zshrc ./ \
  && mv dot_files/.config ./ \
  && mv dot_files/.tmux.conf ./ \
  && mv dot_files/.gitignore_global ./ \
  && rm -rf dot_files \
  && nvim --headless +'PlugInstall' +qall \
  && git config --global core.excludesfile ~/.gitignore_global \
  && mkdir src

CMD ["zsh"]
