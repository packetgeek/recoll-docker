FROM  debian:buster-slim
MAINTAINER joatd

# install important dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	antiword \
	apache2 \
	git \
	libxml2 \
	net-tools \
	poppler-utils \
	python3 \
	python3-chm \
	python3-libxml2 \
	python-libxslt1 \
	python3-lxml \
	python3-pip \
	unrtf \
        unzip \
	vim 
RUN pip3 install waitress

# install recollcmd from recolls programmers website
RUN apt-get install -y --no-install-recommends gnupg
COPY recoll.gpg  /root/recoll.gpg
RUN gpg --import  /root/recoll.gpg
RUN gpg --export '7808CE96D38B9201' | apt-key add -
RUN apt-get install --reinstall -y ca-certificates
RUN apt-get update
RUN echo deb http://www.lesbonscomptes.com/recoll/debian/ buster main > \
        /etc/apt/sources.list.d/recoll.list
RUN echo deb-src http://www.lesbonscomptes.com/recoll/debian/ buster main >> \
        /etc/apt/sources.list.d/recoll.list
RUN apt-get install -y --no-install-recommends recollcmd python3-recoll
RUN apt-get autoremove

# clean up
RUN apt-get clean

COPY recollstatus.py /usr/bin/recollstatus
RUN chmod a+x /usr/bin/recollstatus

#RUN mkdir /docs && mkdir /root/.recoll
RUN mkdir /root/.recoll
COPY recoll.conf /root/.recoll/recoll.conf

RUN cd / && git clone https://framagit.org/medoc92/recollwebui.git

COPY result.tpl /recollwebui/views/result.tpl
RUN chown root: /recollwebui/views/result.tpl
RUN chmod 644 /recollwebui/views/result.tpl

RUN ln -s /docs /var/www/html/docs

VOLUME /var/www/html/docs
VOLUME /root/.recoll
EXPOSE 80
EXPOSE 8080

CMD ["/usr/bin/python3", "/recollwebui/webui-standalone.py", "-a", "0.0.0.0"]
