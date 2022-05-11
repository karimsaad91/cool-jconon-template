# DOCKER-VERSION 1.12
FROM anapsix/alpine-java:jdk8
MAINTAINER Marco Spasiano <marco.spasiano@cnr.it>

#Imposta fuso orario
RUN apk update
RUN apk add tzdata
RUN cp /usr/share/zoneinfo/Europe/Rome /etc/localtime
RUN echo "Europe/Rome" > /etc/timezone

#Copia script update cert. io
COPY ./api-italia-cron.sh /opt/api-italia-cron.sh
RUN apk add openssl
RUN sh /opt/api-italia-cron.sh

RUN adduser -D -s /bin/sh jconon
WORKDIR /home/jconon
USER jconon

ADD target/*.war /opt/jconon.war

EXPOSE 8080

# https://spring.io/guides/gs/spring-boot-docker/#_containerize_it
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/opt/jconon.war"]