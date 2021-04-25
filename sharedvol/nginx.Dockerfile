FROM public.ecr.aws/nginx/nginx:latest

COPY sharedvol/proxy.conf /etc/nginx/conf.d/default.conf
