#!/bin/sh

echo -n | openssl s_client -connect api.io.italia.it:443 -servername api.io.italia.it | openssl x509 > /opt/api.io.italia.it.crt

/opt/jdk/bin/keytool -delete 			\
-alias api.io.italia.it 			\
-keystore /opt/jdk/jre/lib/security/cacerts 	\
-storepass changeit

/opt/jdk/bin/keytool -import 			\
-file /opt/api.io.italia.it.crt 		\
-alias api.io.italia.it 			\
-keystore /opt/jdk/jre/lib/security/cacerts 	\
-noprompt 					\
-storepass changeit
