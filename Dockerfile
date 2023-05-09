# DOCKER-VERSION 1.12
FROM anapsix/alpine-java:jdk8
MAINTAINER Marco Spasiano <marco.spasiano@cnr.it>

#Imposta fuso orario
RUN apk update
RUN apk add tzdata
RUN cp /usr/share/zoneinfo/Europe/Rome /etc/localtime
RUN echo "Europe/Rome" > /etc/timezone

#Certificati SSL per Io e SSO Keycloak
COPY ./ssl-io.sh /opt/ssl-io.sh
COPY ./ssl-keycloak.sh /opt/ssl-keycloak.sh
COPY ./ssl-cron.sh /opt/ssl-cron.sh
RUN apk add openssl
RUN chmod +x /opt/ssl-cron.sh
RUN chmod +x /opt/ssl-io.sh
RUN chmod +x /opt/ssl-keycloak.sh
RUN /opt/ssl-keycloak.sh
RUN adduser -D -s /bin/sh jconon
WORKDIR /home/jconon
USER jconon

ADD target/*.war /opt/jconon.war

EXPOSE 8080

# https://spring.io/guides/gs/spring-boot-docker/#_containerize_it
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/opt/jconon.war"]
