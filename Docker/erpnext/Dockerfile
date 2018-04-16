FROM ubuntu:16.04
MAINTAINER rakshit@improwised.com

# Python's messages
ENV PYTHONUNBUFFERED = 1
# Generate locale C.UTF-8 for mariadb and general locale data
ENV LANG C.UTF-8

# Build args
ARG FRAPPE_USER=frappe
ARG BENCH_BRANCH=master
ARG BENCH_REPO=https://github.com/frappe/bench.git
ARG FRAPPE_BRANCH=v10.1.22
ARG FRAPPE_REPO=https://github.com/frappe/frappe.git
ARG ERPNEXT_BRANCH=v10.1.21
ARG ERPNEXT_REPO=https://github.com/frappe/erpnext.git
ARG ERPNEXT_SITE=site1.local
ARG TIMEZONE=Asia/Kolkata
ARG DOCKERIZE_VERSION=v0.6.1

# TZ
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone && \
    # dpkg-reconfigure -f noninteractive tzdata && \
    date

USER root
RUN apt-get update \
  && apt-get install -y iputils-ping \
    git build-essential python-setuptools python-dev libffi-dev libssl-dev \
    redis-tools software-properties-common libxrender1 libxext6 xfonts-75dpi xfonts-base \
    libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev python-tk \
    apt-transport-https libsasl2-dev libldap2-dev libtiff5-dev tcl8.6-dev tk8.6-dev \
    wget curl rlwrap redis-tools nano wkhtmltopdf sudo vim \
    libmysqlclient-dev mariadb-client mariadb-common
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
RUN pip install --upgrade setuptools pip
RUN adduser --disabled-password --gecos '' $FRAPPE_USER && adduser $FRAPPE_USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get install -y nodejs

USER $FRAPPE_USER
WORKDIR /home/$FRAPPE_USER

RUN git clone -b $BENCH_BRANCH --depth 1 $BENCH_REPO bench-repo && \
    sudo pip install -e /home/$FRAPPE_USER/bench-repo --no-cache-dir && \
    sudo npm install -g yarn && \
    sudo chown -R $FRAPPE_USER:$(id -gn $FRAPPE_USER) /home/$FRAPPE_USER && \
    mkdir -p frappe-bench && cd frappe-bench && \
    mkdir -p apps logs sites/localhost config && \
    bench setup env && \
    sudo bench setup sudoers $FRAPPE_USER && \
    bench setup socketio

RUN bench init frappe-bench --ignore-exist --skip-redis-config-generation --frappe-path $FRAPPE_REPO --frappe-branch $FRAPPE_BRANCH

WORKDIR /home/$FRAPPE_USER/frappe-bench

RUN bench get-app erpnext $ERPNEXT_REPO --branch $ERPNEXT_BRANCH

# Dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && sudo tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && rm *.tar.gz


# Frappe config
#COPY ./config/site_config.json /home/$FRAPPE_USER/frappe-bench/sites/common_site_config.json
#COPY ./config/site_config.json /home/$FRAPPE_USER/frappe-bench/sites/localhost/site_config.json
#COPY ./config/apps.txt /home/$FRAPPE_USER/frappe-bench/sites/apps.txt
#RUN sudo chown -R $FRAPPE_USER:$FRAPPE_USER /home/$FRAPPE_USER/frappe-bench/sites
COPY ./config/ /tmp/config
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN cp /tmp/config/apps.txt /home/$FRAPPE_USER/frappe-bench/sites/apps.txt \
  && cp /tmp/config/supervisord.conf /etc/supervisor/supervisord.conf \
  && sudo chmod +x /usr/local/bin/docker-entrypoint.sh

# Frappe Logs
# VOLUME /home/$FRAPPE_USER/frappe-bench
VOLUME /home/$FRAPPE_USER/frappe-bench/logs
VOLUME /home/$FRAPPE_USER/frappe-bench/sites/localhost

# EntryPoint
ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ['supervisor', '-c', '/etc/supervisor.conf']
