FROM public.ecr.aws/nginx/nginx:latest

RUN apt-get update \
    && apt-get install ssl-cert -y \
    && apt-get clean

COPY tcp/proxy.conf /etc/nginx/conf.d/default.conf

EXPOSE 443
