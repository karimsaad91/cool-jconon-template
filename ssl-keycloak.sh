#!/bin/sh

echo -n | openssl s_client -connect sso.aspbassaromagna.it:443 -servername sso.aspbassaromagna.it | openssl x509 > /opt/sso.aspbassaromagna.it.crt

/opt/jdk/bin/keytool -delete 			\
-alias sso.aspbassaromagna.it 			\
-keystore /opt/jdk/jre/lib/security/cacerts 	\
-storepass changeit

/opt/jdk/bin/keytool -import 			\
-file /opt/sso.aspbassaromagna.it.crt 		\
-alias sso.aspbassaromagna.it			\
-keystore /opt/jdk/jre/lib/security/cacerts 	\
-noprompt 					\
-storepass changeit