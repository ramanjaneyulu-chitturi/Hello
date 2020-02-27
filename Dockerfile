FROM ubuntu:18.04
MAINTAINER DIVA-DEVOPS
RUN apt-get update && apt-get upgrade -y 
RUN apt-get install python -y && apt-get install python-pip -y \
	&& apt-get install libmysqlclient-dev -y \
	&& apt-get install libsasl2-dev python-dev libldap2-dev libssl-dev build-essential -y

RUN mkdir -p /var/www/html
WORKDIR /var/www/html
COPY . .
RUN pip install -r NNC_Django/requirements.txt
VOLUME ["/var/www/html/NNC_Django"]
RUN mkdir -p /var/log/NNCDjango/ && touch /var/log/NNCDjango/NNCDjangoLogs.log
EXPOSE 8000 80
RUN mkdir -p /etc/uwsgi/sites \
	&& adduser --system --no-create-home --disabled-login --disabled-password --group uwsgi \
	&& chown -R uwsgi:uwsgi /etc/uwsgi 

RUN  apt-get install -y nginx && \
     rm -rf /var/lib/apt/lists/* && \
     echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
     rm -rf /etc/nginx/sites-available/default && \
     chown -R www-data:www-data /var/lib/nginx

COPY default2 /etc/nginx/sites-available/default

#RUN echo "\n10.0.0.18 reports_writw_db" >> /etc/hosts
CMD ["/bin/sh", "-c" , "echo 10.0.0.18 reports_writw_db >> /etc/hosts && echo 10.0.0.18 colo_ssd_slave >> /etc/hosts && echo 10.0.0.18 rancho_master >> /etc/hosts && echo 10.0.0.18 reports_db  >> /etc/hosts && echo 10.0.0.18 msp_db >> /etc/hosts &&  uwsgi --master --die-on-term --processes 20 --threads 40 --max-fd 8000 --listen 120 --thunder-lock --harakiri 120 --enable-threads --http :8000 --chdir /var/www/html/NNC_Django -w NNCPortal.wsgi --logto /var/www/html/NNC_Django/uwsgi_nncdjango.log && nginx "]

