# This combined service needs both the nginx and python runtimes, as well
# as the process supervisor to be the PID 1 for the container.

# In this one, we use mutli-stage build, to get the version of nginx we want
# without having to jump through hoops of distro installation.
FROM public.ecr.aws/nginx/nginx:latest as nginx
# nothing to do here, we're not customizing this layer.

FROM python:3-slim
ENV PYTHONUNBUFFERED=1

# https://github.com/just-containers/s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

# From https://git.io/JO7Wr
RUN addgroup --system --gid 101 nginx \
    && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx
# Pull over the defaults from the other image
COPY --from=nginx /etc/nginx/ /etc/nginx/
COPY --from=nginx /usr/sbin/nginx /usr/sbin/nginx
COPY --from=nginx /var/cache/nginx /var/cache/nginx
COPY --from=nginx /var/log/nginx /var/log/nginx

RUN apt update \
    && apt install gcc -y \
    && apt clean
RUN pip install --no-cache-dir poetry

WORKDIR /app

COPY poetry.lock pyproject.toml /app/
RUN poetry config virtualenvs.create false && poetry install --no-dev

COPY combined/services/nginx.sh /etc/services.d/nginx/run
COPY combined/services/gunicorn.sh /etc/services.d/gunicorn/run
COPY combined/services/finish.sh /etc/services.d/gunicorn/finish
# We're using a debian distro version of nginx, overwrite distro-provided file
# COPY combined/proxy.conf /etc/nginx/sites-enabled/default
COPY combined/proxy.conf /etc/nginx/conf.d/default.conf

COPY . /app

# We only expose the nginx port
EXPOSE 80

# This is the s6 init. Services live in /etc/services.d/*
ENTRYPOINT ["/init"]
