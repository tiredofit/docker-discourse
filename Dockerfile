FROM registry.selfdesign.org/docker/alpine:edge
MAINTAINER Dave Conroy <dave at tiredofit dot ca>

### Environment Variables
   ENV DISCOURSE_VERSION=1.8.4 \
       RAILS_ENV=production \
       RUBY_GC_MALLOC_LIMIT=90000000 \
       RUBY_GLOBAL_METHOD_CACHE_SIZE=131072 \
       LIBV8_MAJOR=5.3.332.38 \
       LIBV8_VERSION=5.3.332.38.5-x86_64-linux \
       DISCOURSE_DB_HOST=postgres \
       DISCOURSE_REDIS_HOST=redis \
       DISCOURSE_SERVE_STATIC_ASSETS=true

### Set Basedir
   WORKDIR /app

### Install Dependencies
   RUN apk update && \
       apk add --no-cache \
   		  autoconf \
 		    build-base \
		    ghostscript \
		    gifsicle \
		    git \
		    ghostscript-fonts \
		    imagemagick \
		    jpegoptim \
		    libbz2 \
		    libffi-dev \
		    libjpeg \
		    libpq \
		    libxslt-dev \
		    libxml2 \
		    libxml2-dev \
		    linux-headers \
		    nodejs \
		    nodejs-npm \
		    optipng \
		    pkgconfig \
		    postgresql-client \
		    pngquant \
        python2 \
        python2-dev \
        ruby \
        ruby-bundler \
        ruby-dev \
		    && \
	    
    #ln --symbolic /usr/bin/nodejs /usr/bin/node && \
    npm install --global \
        svgo \
        uglify-js@2.8.27 
    
    # install libv8
RUN    mkdir -p /usr/src && \
    cd /usr/src && \
    git clone --recursive git://github.com/cowboyd/libv8.git && \
    cd libv8 && \
    sed -i -e 's/Gem::Platform::RUBY/Gem::Platform.local/' libv8.gemspec && \
    gem build libv8.gemspec && \
    export GYP_DEFINES="$GYP_DEFINES linux_use_bundled_binutils=0 linux_use_bundled_gold=0"

RUN    gem install --verbose libv8-$LIBV8_VERSION.gem && \
    cd /usr/local/bundle/gems/libv8-$LIBV8_VERSION/vendor/ && \
    mkdir -p /tmp/v8 && \
    mv ./v8/out /tmp/v8/ && \
    mv ./v8/include /tmp/v8 && \
    rm -rf ./v8 ./depot_tools && \
    mv /tmp/v8 .
    #bundle install && \
    #bundle exec rake compile && \

### Download Discourse
   RUN curl -sfSL https://github.com/discourse/discourse/archive/v${DISCOURSE_VERSION}.tar.gz | tar -zx --strip-components=1 -C /app && \

### Install Plugins    
        cd /app/plugins && \
        ## SQL Query Explorer 
        git clone https://github.com/discourse/discourse-data-explorer.git && \ 
        ## Allow Accepted Answers on Topics
        git clone https://github.com/discourse/discourse-solved && \ 
        ## Adds the ability for voting on a topic in category
        git clone https://github.com/discourse/discourse-voting.git && \ 
        ## LDAP Plugin
        #git clone https://github.com/jonmbake/discourse-ldap-auth && \
        ## SAML Plugin
        #git clone https://github.com/discourse/discourse-saml && \
        cd /app && \

### Install Discourse
  	bundle config build.nokogiri --use-system-libraries && \
    bundle install --deployment --without test --without development 
    
#        rm -rf /root/.npm /app/vendor/bundle/ruby/2.3.0/cache/* /tmp/* /usr/src/*

### Add Logrotate
   ADD install/logrotate.d /etc/logrotate.d

### S6
   ADD install/s6 /etc/s6

### Networking Configuration
   EXPOSE 3000

### Entrypoint Configuration
   ENTRYPOINT ["/init"]
