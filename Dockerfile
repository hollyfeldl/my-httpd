FROM httpd:latest
COPY ./ssl/markrank.pem /usr/local/apache2/conf/markrank.pem
COPY ./ssl/markrank-key.pem /usr/local/apache2/conf/markrank-key.pem
COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf
COPY ./html/ /usr/local/apache2/htdocs/

