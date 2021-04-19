FROM public.ecr.aws/nginx/nginx:latest

COPY tcp/proxy.conf /etc/nginx/conf.d/default.conf
