ARG DISTRO="debian"
ARG DISTRO_VARIANT="bookworm"

FROM docker.io/tiredofit/nginx:${DISTRO}-${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG DISCOURSE_VERSION
ARG RUBY_VERSION

### Environment Variables
ENV DISCOURSE_VERSION=${DISCOURSE_VERSION:-"v3.3.3"} \
    RUBY_VERSION=${RUBY_VERSION:-"3.3.6"} \
    RUBY_ALLOCATOR=/usr/lib/libjemalloc.so.2 \
    RAILS_ENV=production \
    RUBY_GC_MALLOC_LIMIT=90000000 \
    RUBY_GLOBAL_METHOD_CACHE_SIZE=131072 \
    ENABLE_NGINX=FALSE \
    NGINX_MODE=PROXY \
    NGINX_PROXY_URL=http://127.0.0.1:3000 \
    NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE \
    IMAGE_NAME="tiredofit/discourse" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-discourse/"

### Install Dependencies
RUN source /assets/functions/00-container && \
    BUILD_DEPS=" \
                build-essential \
                g++ \
                gcc \
                gettext \
                libbz2-dev \
                libfreetype6-dev \
                libicu-dev \
                libjemalloc-dev \
                libjpeg-dev \
                libssl-dev \
                libpq-dev \
                libtiff-dev \
                libxslt-dev \
                libxml2-dev \
                libyaml-dev \
                make \
                patch \
                pkg-config \
                zlib1g-dev \
                " && \
    set -x && \
    addgroup --gid 9009 --system discourse && \
    adduser --uid 9009 --gid 9009 --home /dev/null --gecos "Discourse" --shell /sbin/nologin --disabled-password discourse && \
    curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo "deb https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodejs.list && \
    curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    curl -ssL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(cat /etc/os-release |grep "VERSION=" | awk 'NR>1{print $1}' RS='(' FS=')')-pgdg main" > /etc/apt/sources.list.d/postgres.list && \
    package update && \
    package upgrade -y && \
    package install \
                ${BUILD_DEPS} \
                advancecomp \
                brotli \
                ghostscript \
                gifsicle \
                git \
                gsfonts \
                imagemagick \
                jhead \
                jpegoptim \
                libicu72 \
                libjemalloc2 \
                libjpeg-turbo-progs \
                libpq5 \
                libssl3 \
                libxml2 \
                nodejs \
                npm \
                optipng \
                pngquant \
                postgresql-client-17 \
                postgresql-contrib-17 \
                yarn \
                zlib1g \
                && \
    \
    mkdir -p /usr/src/oxipng && \
    curl -sSL https://github.com/shssoichiro/oxipng/releases/download/v7.0.0/oxipng-7.0.0-x86_64-unknown-linux-musl.tar.gz | tar xvfz - --strip 1 -C /usr/src/oxipng && \
    cp -R /usr/src/oxipng/oxipng /usr/bin && \
    \
    ### Setup Ruby
    mkdir -p /usr/src/ruby && \
    curl -sSL https://cache.ruby-lang.org/pub/ruby/$(echo ${RUBY_VERSION} | cut -c1-3)/ruby-${RUBY_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/ruby && \
    cd /usr/src/ruby && \
    ./configure \
                --disable-install-rdoc \
                --enable-shared \
                --with-jemalloc \
                && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    \
    echo 'gem: --no-document' >> /usr/local/etc/gemrc && \
    gem update --system && \
    \
    npm install --global \
        svgo \
        terser \
        uglify-js \
        pnpm \
        && \
    \
    ### Download Discourse
    clone_git_repo "https://github.com/discourse/discourse" "${DISCOURSE_VERSION}" /app && \
    BUNDLER_VERSION="$(grep "BUNDLED WITH" Gemfile.lock -A 1 | grep -v "BUNDLED WITH" | tr -d "[:space:]")" && \
    gem install bundler:"${BUNDLER_VERSION}" && \
    chown -R discourse:discourse /app && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle config --local path ./vendor/bundle && \
    bundle config set --local deployment true && \
    bundle config set --local without development test && \
    bundle install --jobs $(nproc) && \
    cd /app && \
    git config --global --add safe.directory /app && \
    yarn install --frozen-lockfile && \
    yarn run postinstall && \
    yarn cache clean && \
    find /app/vendor/bundle -name tmp -type d -exec rm -rf {} + && \
    curl -sSL https://git.io/GeoLite2-ASN.mmdb -o /app/vendor/data/GeoLite2-ASN.mmdb && \
    curl -sSL https://git.io/GeoLite2-City.mmdb -o /app/vendor/data/GeoLite2-City.mmdb && \
    sed  -i "5i\ \ require 'uglifier'" /app/config/environments/production.rb && \
    sed -i "s|config.assets.js_compressor = :uglifier|config.assets.js_compressor = Uglifier.new(harmony: true)|g" /app/config/environments/production.rb  && \
    ln -sf "$(which convert)" "/usr/bin/magick" && \
    \
#### Install Plugins
    mkdir -p /assets/discourse/plugins && \
    mv /app/plugins/* /assets/discourse/plugins && \
    rm -rf /assets/discourse/plugins/discourse-nginx-performance-report && \
    ### Allow Same Origin
    git clone https://github.com/TheBunyip/discourse-allow-same-origin.git /assets/discourse/plugins/allow-same-origin && \
    ### Allow Accepted Answers on Topics
    git clone https://github.com/discourse/discourse-solved /assets/discourse/plugins/solved && \
    #### Assign Plugin
    git clone https://github.com/discourse/discourse-assign /assets/discourse/plugins/assign && \
    #### Events Plugin
    git clone https://github.com/angusmcleod/discourse-events /assets/discourse/plugins/events && \
    #### Formatting Toolbar Plugin
    git clone https://github.com/MonDiscourse/discourse-formatting-toolbar /assets/discourse/plugins/formatting-toolbar && \
    #### Mermaid
    git clone https://github.com/unfoldingWord/discourse-mermaid /assets/discourse/plugins/discourse-mermaid && \
    #### Post Voting
    git clone https://github.com/discourse/discourse-post-voting /assets/discourse/plugins/post-voting && \
    ### Push Notifications
    git clone https://github.com/discourse/discourse-push-notifications /assets/discourse/plugins/push && \
    ### Adds the ability for voting on a topic in category
    git clone https://github.com/discourse/discourse-voting.git /assets/discourse/plugins/voting && \
    chown -R discourse:discourse \
                                /assets/discourse \
                                /app \
                                && \
### Cleanup
    package remove ${BUILD_DEPS} && \
    package cleanup && \
    rm -rf \
        /app/.devcontainer \
        /app/.editorconfig \
        /app/.github \
        /app/.*ignore \
        /app/.prettier* \
        /app/.vscode-sample \
        /app/bin/docker \
        /app/Brewfile \
        /app/CODEOWNERS \
        /app/CONTRIBUTING.md \
        /app/config/dev_defaults.yml \
        /app/config/*.sample \
        /app/config/logrotate.conf \
        /app/config/multisite.yml.production-sample \
        /app/config/nginx* \
        /app/config/puma* \
        /app/config/unicorn_upstart.conf \
        /app/deploy.rb.sample \
        /app/d \
        /app/discourse.sublime-project \
        /app/install-imagemagick \
        /app/lefthook.yml \
        /app/test \
        /app/translator.yml \
        /app/vendor/bundle/ruby/${RUBY_VERSION:0:3}/cache/* \
        /root/.bundle \
        /root/.config \
        /root/.local \
        /root/.npm \
        /root/.profile \
        /tmp/* \
        /usr/src/*

WORKDIR /app
EXPOSE 3000
COPY install/ /
