FROM alpine
#RUN apt update && apt install net-tools -y && apt install nginx -y
RUN apk add --update nginx
COPY index.html /usr/share/nginx/html/index.html
COPY default.conf /etc/nginx/http.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
