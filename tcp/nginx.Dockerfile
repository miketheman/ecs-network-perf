FROM public.ecr.aws/nginx/nginx:latest

COPY tcp/templates/default.conf.template /etc/nginx/templates/
