FROM debian:stretch

ENV DEBIAN_URL "http://ftp.us.debian.org/debian"

RUN echo "deb $DEBIAN_URL testing main contrib non-free" >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y \
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
    lua5.3 \
    openssl \
    pkg-config \
    sqlite3 \
    tmux \
    unzip \
    xclip \
    xfonts-utils \
    zlib1g-dev \
    zsh \
  && apt-get clean all

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

# setup workspace
WORKDIR $HOME
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH "$PYENV_ROOT/shims:$PYENV_ROOT/bin:$HOME/.local/bin:${PATH}"

# setup pyenv
RUN git clone --depth 1 git://github.com/yyuu/pyenv.git .pyenv
RUN pyenv install 3.7.2
RUN pyenv global 3.7.2
RUN pyenv rehash

RUN pip install --user neovim

ENTRYPOINT /usr/bin/zsh
