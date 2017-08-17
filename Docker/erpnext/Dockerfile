FROM python:2.7-stretch
MAINTAINER meigallo@meigallodixital.com

# Python's messages
ENV PYTHONUNBUFFERED = 1

# Build args
ARG FRAPPE_USER
ARG BENCH_BRANCH
ARG BENCH_REPO
ARG FRAPPE_BRANCH
ARG FRAPPE_REPO
ARG ERPNEXT_BRANCH
ARG ERPNEXT_REPO
ARG ERPNEXT_SITE
ARG TIMEZONE
ARG DOCKERIZE_VERSION


# TZ
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    date

# Dependences install
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git-core sudo build-essential software-properties-common \
    libssl-dev mariadb-client libmariadbclient-dev dirmngr python-mysqldb \
    wkhtmltopdf supervisor curl python-pip redis-server && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade setuptools && \
    pip install MySQL-python --no-use-wheel

# Nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get install -y nodejs

# Add frappe user
RUN adduser --disabled-password --gecos '' $FRAPPE_USER && adduser $FRAPPE_USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Frappe install
USER $FRAPPE_USER
WORKDIR /home/$FRAPPE_USER
RUN git clone -b $BENCH_BRANCH --depth 1 $BENCH_REPO bench-repo && \
    sudo pip install -e /home/$FRAPPE_USER/bench-repo --no-cache-dir && \
    mkdir -p frappe-bench && cd frappe-bench && \
    mkdir -p apps logs sites/localhost config && \
    bench setup env && \
    sudo bench setup sudoers $FRAPPE_USER && \
    bench setup socketio && \
    bench get-app frappe $FRAPPE_REPO --branch $FRAPPE_BRANCH


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
RUN sudo chmod +x /usr/local/bin/docker-entrypoint.sh
RUN cp /tmp/config/apps.txt /home/$FRAPPE_USER/frappe-bench/sites/apps.txt && \
    sudo chmod +x /usr/local/bin/docker-entrypoint.sh

# Supervisord config
COPY  ./config/supervisord.conf /etc/supervisor/supervisord.conf

# Frappe Logs
VOLUME /home/$FRAPPE_USER/frappe-bench/logs
VOLUME /home/$FRAPPE_USER/frappe-bench/sites/localhost

# App dir
WORKDIR /home/$FRAPPE_USER/frappe-bench

# EntryPoint
ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]
# CMD  ['/bin/bash']
