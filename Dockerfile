FROM httpd:latest
COPY ./markrank.pem /usr/local/apache2/conf/markrank.pem
COPY ./markrank-key.pem /usr/local/apache2/conf/markrank-key.pem
COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
COPY ./http/ /usr/local/apache2/htdocs/ 
