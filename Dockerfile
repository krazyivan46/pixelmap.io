FROM ubuntu:bionic
WORKDIR /var/www/html

# Install Python3
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

# Install Requirements
RUN apt-get update && apt-get install python-pip python-dev iputils-ping \
    build-essential apache2 supervisor software-properties-common curl git \
    wget vim -y && pip install --upgrade pip
RUN add-apt-repository -y ppa:ethereum/ethereum
RUN apt-get update && apt-get install -y ethereum redis-server

# Install Parity
RUN wget https://releases.parity.io/v1.11.8/x86_64-unknown-linux-gnu/parity_1.11.8_ubuntu_amd64.deb && \
    dpkg -i parity_1.11.8_ubuntu_amd64.deb

# Install Python Packages
RUN pip3 install requests web3 redis Pillow jinja2 gevent

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Better Bashrc
COPY .bashrc /.bashrc
COPY .bashrc /root/.bashrc

# Copy in Code
COPY . /var/www/html/

# Apache
ENTRYPOINT /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
EXPOSE 80
