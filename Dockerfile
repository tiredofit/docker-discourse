FROM tiredofit/ruby:2.3-1.0-debian
MAINTAINER Dave Conroy <dave at tiredofit dot ca>

### Environment Variables
   ENV DISCOURSE_VERSION=1.8.4 \
       RAILS_ENV=production \
       RUBY_GC_MALLOC_LIMIT=90000000 \
       RUBY_GLOBAL_METHOD_CACHE_SIZE=131072 \
       DISCOURSE_DB_HOST=postgres \
       DISCOURSE_REDIS_HOST=redis \
       DISCOURSE_SERVE_STATIC_ASSETS=true

### Set Basedir
   WORKDIR /app

### Install Dependencies
   RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' >>/etc/apt/sources.list && \
       curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
       apt-get update && \
       apt-get install -y --no-install-recommends \
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
		    npm \
		    optipng \
		    pkg-config \
		    postgresql-client \
		    pngquant \
		    && \
	    
    ln --symbolic /usr/bin/nodejs /usr/bin/node && \
    npm install --global \
        svgo \
        uglify-js@2.8.27 && \
    rm -rf /var/lib/apt/lists/* && \

### Download Discourse
        curl -sfSL https://github.com/discourse/discourse/archive/v${DISCOURSE_VERSION}.tar.gz | tar -zx --strip-components=1 -C /app && \


### Install Discourse
        cd /app && \
	bundle config build.nokogiri --use-system-libraries && \
    	bundle install --deployment --without test --without development 

### Install Plugins    
    RUN cd /app/plugins && \
        ## Remove Nginx Performance Plugin
        rm -rf /app/plugins/discourse-nginx-performance-report && \

        ## SQL Query Explorer 
        git clone https://github.com/discourse/discourse-data-explorer.git /app/plugins/sql-explorer && \ 
        ## Allow Accepted Answers on Topics
        git clone https://github.com/discourse/discourse-solved /app/plugins/solved && \ 
        ## Adds the ability for voting on a topic in category
        git clone https://github.com/discourse/discourse-voting.git /app/plugins/voting && \ 
        cd /app && \

### Cleanup
    	#apt-get purge -y build-essential && \
    	apt-get clean && \
	apt-get autoremove -y && \
        rm -rf /app/vendor/bundle/ruby/2.3.0/cache/* /tmp/* /usr/src/*
        

### Add Logrotate
   ADD install/logrotate.d /etc/logrotate.d

### S6 Overlay
   ADD install/s6 /etc/s6

### Networking Configuration
   EXPOSE 3000

### Entrypoint Configuration
   ENTRYPOINT ["/init"]
