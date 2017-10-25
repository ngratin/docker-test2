FROM ubuntu:16.04

ENV RUBY_INSTALL_VERSION 0.6.1
ENV RUBY_VERSION 2.2

RUN apt-get update && apt-get install -y --no-install-recommends \
		apache2 \
		apache2-dev \
		bison \
		build-essential \
		ca-certificates \
		git \
		libapr1-dev \
		libaprutil1-dev \
		libcurl4-openssl-dev \
		libffi-dev \
		libgdbm-dev \
		libmysqlclient-dev \
		libpq-dev \
		libncurses5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libyaml-dev \
		make \
		nodejs \
                supervisor \
		wget \
		zlib1g-dev \
        && apt-get clean \
        && rm -fr /var/lib/apt/lists/*

RUN wget -O ruby-install-0.6.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.1.tar.gz \
	&& tar -zxf ruby-install-0.6.1.tar.gz

WORKDIR /ruby-install-0.6.1

RUN make install

RUN ruby-install --system ruby 2.2 -- --disable-install-rdoc
RUN gem update --system
RUN gem install passenger bundler --no-ri --no-rdoc
RUN passenger-install-apache2-module

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config /config
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY run.sh /run.sh
COPY startup.sh /startup.sh

RUN chmod 755 /*.sh

CMD ["/run.sh"]
