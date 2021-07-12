FROM tiredofit/ruby:2.6-debian
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

### Environment Variables
ENV DISCOURSE_VERSION=2.6.0.beta1 \
    BUNDLER_VERSION=2.0.2 \
    RAILS_ENV=production \
    RUBY_GC_MALLOC_LIMIT=90000000 \
    RUBY_GLOBAL_METHOD_CACHE_SIZE=131072 \
    DISCOURSE_DB_HOST=discourse-db \
    DISCOURSE_REDIS_HOST=discrouse-redis \
    DISCOURSE_SERVE_STATIC_ASSETS=true

### Set Basedir
WORKDIR /app

### Install Dependencies
RUN set -x && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >>/etc/apt/sources.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    curl --silent --location https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y --no-install-recommends \
        advancecomp \
        autoconf \
        build-essential \
        ghostscript \
        gifsicle \
        git \
        gsfonts \
        imagemagick \
        jhead \
        jpegoptim \
        libbz2-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libjpeg-turbo-progs \
        libpq-dev \
        libtiff-dev \
        libxslt-dev \
        libxml2 \
        libxml2-dev \
        nodejs \
        optipng \
        pkg-config \
        postgresql-client \
        pngquant \
        zlib1g-dev \
        && \
    \
    npm install --global \
        svgo \
        && \
    \
    gem uninstall bundler && \
    gem install bundler && \
    \
### Download Discourse
    curl -sfSL https://github.com/discourse/discourse/archive/v${DISCOURSE_VERSION}.tar.gz | tar -zx --strip-components=1 -C /app
### Install Discourse
    RUN cd /app && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install --deployment --without test --without development && \
    \
    sed  -i "5i\ \ require 'uglifier'" /app/config/environments/production.rb && \
    sed -i "s|config.assets.js_compressor = :uglifier|config.assets.js_compressor = Uglifier.new(harmony: true)|g" /app/config/environments/production.rb  && \
    sed -i "281d" /app/lib/tasks/assets.rake && \
    \
### Install Plugins
    cd /app/plugins && \
    ## Remove Nginx Performance Plugin
    rm -rf /app/plugins/discourse-nginx-performance-report && \
    ## SQL Query Explorer
    git clone https://github.com/discourse/discourse-data-explorer.git /app/plugins/sql-explorer && \
    ## Allow Accepted Answers on Topics
    git clone https://github.com/discourse/discourse-solved /app/plugins/solved && \
    ## Adds the ability for voting on a topic in category
    git clone https://github.com/discourse/discourse-voting.git /app/plugins/voting && \
    ## Push Notifications
    git clone https://github.com/discourse/discourse-push-notifications /app/plugins/push && \
    ## Chat Notification
    #git clone https://github.com/discourse/discourse-chat-integration /app/plugins/chat && \
    ### Assign Plugin
    #git clone https://github.com/discourse/discourse-assign /app/plugins/assign && \
    ### Events Plugin
    #git clone https://github.com/angusmcleod/discourse-events /app/plugins/events && \
    ## Checklist Plugin
    git clone https://github.com/cpradio/discourse-plugin-checklist /app/plugins/checklist && \
    ## Allow Same Origin
    git clone https://github.com/TheBunyip/discourse-allow-same-origin.git /app/plugins/allow-same-origin && \
    \
### Cleanup
    #apt-get purge -y build-essential && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /app/vendor/bundle/ruby/2.6.0/cache/* /tmp/* /usr/src/*

### Networking Configuration
EXPOSE 3000

### Add files
ADD install/ /
