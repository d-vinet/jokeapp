FROM python:3-slim-buster
# Install all the required packages
WORKDIR /app
RUN chmod 777 /app
RUN apt-get -qq update
RUN apt-get -qq install -y --no-install-recommends curl git gnupg2 unzip wget pv jq


# install required packages
RUN apt-get update && apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-add-repository non-free && \
    apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    # this package is required to fetch "contents" via "TLS"
    apt-transport-https \
    # install coreutils
    coreutils gcc g++ \
    # install encoding tools
    mediainfo \
    # miscellaneous
    neofetch python3-dev git bash build-essential nodejs npm ruby \
    python-minimal locales python-lxml nginx gettext-base xz-utils \
    # install extraction tools
    p7zip-full p7zip-rar rar unrar zip unzip \
    # miscellaneous helpers
    mediainfo && \
    # clean up the container "layer", after we are done
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV LANG C.UTF-8

# we don't have an interactive xTerm
ENV DEBIAN_FRONTEND noninteractive

# sets the TimeZone, to be used inside the container
ENV TZ Asia/Kolkata

# rclone and fclone
RUN curl https://rclone.org/install.sh | bash && \
    wget https://github.com/mawaya/rclone/releases/download/fclone-v0.4.1/fclone-v0.4.1-linux-amd64.zip && \
    unzip fclone-v0.4.1-linux-amd64.zip && mv fclone-v0.4.1-linux-amd64/fclone /usr/bin/ && chmod +x /usr/bin/fclone && rm -r fclone-v0.4.1-linux-amd64

# gclone v1.58.0-coffee
RUN wget https://github.com/l3v11/gclone/releases/download/v1.58.0-coffee/gclone-v1.58.0-coffee-linux-amd64.zip && \
    unzip gclone-v1.58.0-coffee-linux-amd64.zip && mv gclone-v1.58.0-coffee-linux-amd64/gclone /usr/bin && chmod +x /usr/bin/gclone && rm -r gclone-v1.58.0-coffee-linux-amd64

#drive downloader
RUN curl -L https://github.com/jaskaranSM/drivedlgo/releases/download/1.5/drivedlgo_1.5_Linux_x86_64.gz -o drivedl.gz && \
    7z x drivedl.gz && mv drivedlgo /usr/bin/drivedl && chmod +x /usr/bin/drivedl && rm drivedl.gz

#ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip ngrok-stable-linux-amd64.zip && mv ngrok /usr/bin/ && chmod +x /usr/bin/ngrok

# Copies config(if it exists)
COPY . .

# Install requirements and start the bot
RUN npm install

#install requirements
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# setup workdir
COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx.conf /etc/nginx/nginx.conf
RUN dpkg --add-architecture i386 && apt-get update && apt-get -y dist-upgrade

CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon on;' && cd /app && mkdir Downloads && bash start.sh
