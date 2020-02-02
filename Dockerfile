FROM huaishuo/nginx

COPY ./public /usr/share/nginx/blog

EXPOSE 3000