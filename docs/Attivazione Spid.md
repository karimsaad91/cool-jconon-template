# Attivazione Spid

Breve premessa: nella terminologia Spid, Cool-jconon sarà il SP (Service Provider), mentre Lepida, PosteID, etc, saranno gli IdP (Identity Provider).

## 1. Generazione Metadata SP

Creare un file metadata partendo da questo di esempio, adattando i valori alla propria installazione.

**metadata_non_firmato.xml**

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:spid="https://spid.gov.it/saml-extensions" ID="ID_6ae80aed-3247-4647-bf5f-6f5294cbc2c7" entityID="https://www.aspbassaromagna.it">
	<md:SPSSODescriptor AuthnRequestsSigned="true" WantAssertionsSigned="true" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
		<md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://bandi.aspbassaromagna.it/rest/security/logout"/>
		<md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</md:NameIDFormat>
		<md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://bandi.aspbassaromagna.it/spid/send-response" index="0" isDefault="true"/>
		<md:AttributeConsumingService index="0">
			<md:ServiceName xml:lang="it">Single sign-on</md:ServiceName>
			<md:RequestedAttribute FriendlyName="Email" Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"/>
			<md:RequestedAttribute FriendlyName="Data di nascita" Name="dateOfBirth" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"/>
			<md:RequestedAttribute FriendlyName="Nome" Name="name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"/>
			<md:RequestedAttribute FriendlyName="Cognome" Name="familyName" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"/>
			<md:RequestedAttribute FriendlyName="Sesso" Name="gender" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"/>
			<md:RequestedAttribute FriendlyName="Codice fiscale" Name="fiscalNumber" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"/>
		</md:AttributeConsumingService>
	</md:SPSSODescriptor>
	<md:Organization>
		<md:OrganizationName xml:lang="it">ASP dei Comuni della Bassa Romagna</md:OrganizationName>
		<md:OrganizationName xml:lang="en">ASP dei Comuni della Bassa Romagna</md:OrganizationName>
		<md:OrganizationDisplayName xml:lang="it">ASP dei Comuni della Bassa Romagna</md:OrganizationDisplayName>
		<md:OrganizationDisplayName xml:lang="en">ASP dei Comuni della Bassa Romagna</md:OrganizationDisplayName>
		<md:OrganizationURL xml:lang="it">https://www.aspbassaromagna.it</md:OrganizationURL>
		<md:OrganizationURL xml:lang="en">https://www.aspbassaromagna.it</md:OrganizationURL>
	</md:Organization>
	<md:ContactPerson contactType="other">
		<md:Extensions>
			<spid:IPACode>adcbr</spid:IPACode>
			<spid:Public/>
		</md:Extensions>
		<md:Company>ASP dei Comuni della Bassa Romagna</md:Company>
		<md:EmailAddress>email@email.it</md:EmailAddress>
	</md:ContactPerson>
</md:EntityDescriptor>
```

Da notare che https://bandi.aspbassaromagna.it è il sito che ospita il servizio vero e proprio (cool-jconon), mentre https://www.aspbassaromagna.it è il sito dell'istituzione.

Salvare il file in una cartella di lavoro ad es. **~/certificati/**

## 2. Generazione certificato per firma Metadata SP

Utilizzare il progetto [GitHub - italia/spid-compliant-certificates: Solution to create self-signed certificates according to Avviso SPID n.29](https://github.com/italia/spid-compliant-certificates) per creare i certificati necessari. Adattare ~/certificati/ alla propria cartella di lavoro.

```bash
docker run -ti --rm \
    -v ~/certificati:/certs" \
    italia/spid-compliant-certificates generator \
        --key-size 2048 \
        --common-name "https://bandi.aspbassaromagna.it" \
        --days 3650 \
        --entity-id "https://www.aspbassaromagna.it" \
        --locality-name Bagnacavallo \
        --org-id "PA:IT-abcde" \
        --org-name "ASP dei Comuni della Bassa Romagna" \
        --sector public
```

Creare cert.pkcs12 ed annotarsi la password scelta.

```bash
openssl pkcs12 -export -inkey key.pem -in crt.pem -out cert.pkcs12
```

Copiare **cert.pkcs12** in **~/cool-jconon-template/src/main/resources/keystore/**

Creare il file **~/cool-jconon-template/src/main/resources/idp.yml** partendo da questo esempio: [cool-jconon/idp.yml at 1f9e53ffb85e6cb91190631c19b44943e03040db · consiglionazionaledellericerche/cool-jconon · GitHub](https://github.com/consiglionazionaledellericerche/cool-jconon/blob/1f9e53ffb85e6cb91190631c19b44943e03040db/cool-jconon-spid/src/main/resources/idp.yml) e riportare la password appena creata.

## 3. Firma Metadata SP

Utilizzare il progetto [GitHub - italia/spid-metadata-signer: Tool per la firma del metadata SAML SPID](https://github.com/italia/spid-metadata-signer)

```bash
sudo apt install openjdk-11-jdk openjdk-11-jre 
sudo update-alternatives --config java
#impostare java 11, al termine reimpostare java 8 per cool-jconon

git clone https://github.com/italia/spid-metadata-signer
```

Copiare i file generati al punto 1 e 2 nella cartella **~/spid-metadata-signer/**

Editare il file **~/spid-metadata-signer/.config**

```ini
metadataFileName="metadata_non_firmato.xml"
keyName="key.pem"
keyPass="PASSWORD"
crtName="crt.pem"
javaHome="/usr/lib/jvm/java-11-openjdk-amd64"
```

```bash
./spidMetadataSigner.sh
```

Copiare il file generato in **~/cool-jconon-template/src/main/resources/META-INF/metadata/sp/sp_metadata.xml**



## 4. Validazione Metadata

### Spid Validator Locale

Utilizzare il progetto [GitHub - italia/spid-saml-check: Tool di verifica implementazione SPID SAML](https://github.com/italia/spid-saml-check)

Lo strumento verrà eseguito sulla porta 8089 in quanto la 8080 è già utilizzata da Cool-Jconon.

```bash
docker run -t -i -p 8089:8089 italia/spid-saml-check
```

Modificare all'interno del container i file:

- /spid-saml-check/spid-validator/config/idp.json
- /spid-saml-check/spid-validator/config/server.json

E sostituire tutte le occorrenze di `localhost `con l'ip della macchina host, e `8080` con `8089`

Riavviare il container. Il metadata sarà disponibile all'indirizzo https://indirizzo:8089/metadata.xml 

### Spid Validator Online (consigliato)

Il metadata è disponibile qui https://demo.spid.gov.it/validator/metadata.xml

### Abilitare gli IdP di test

Lo Spid Validator si usa come IdP per validare i "dialoghi" tra SP e IdP.

Per farlo apparire come IdP su Cool-Jconon:

Copiare il metadata dell'IdP in  ~/cool-jconon-template/src/main/resources/metadata/idp (ad es: demovalidator-metadata.xml)

Creare un'icona per l'IdP e copiarla in ~/cool-jconon-template/src/main/resources/META-INF/img (ad es: icona-validator.png)

Modificare ~/cool-jconon-template/src/main/resources/idp.yml e aggiungere:

```yaml
VALIDATORDEMO:
  file: classpath:metadata/idp/demovalidator-metadata.xml
  name: SPID Validator
  imageUrl: res/img/icona-validator.png
  postURL: https://percorso/samlsso
  redirectURL: https://percorso/samlsso
  entityId: https://percorso:8089
  profile: dev
```

postURL, redirectURL, entityId si trovano aprendo il file metadata dell'IdP

profile:  dev indica che questo IdP verrà caricato solo se Cool Jconon è lanciato con SPRING_PROFILES_ACTIVE=asp,dev

### Effettuare il test

Riavviando Cool-Jconon con il profilo dev, apparirà l'IdP di prova. Effettuare l'accesso tramite quest'ultimo e iniziare i vari test.

Procedura disponibile qui: https://github.com/italia/spid-saml-check/blob/master/README.it.md#come-usare-spid-validator

## 5. Diventare fornitore di servizi SPID

Aggiungere l'IdP del Validator ufficiale ( https://validator.spid.gov.it/metadata.xml ) impostando profile: spid-validator

Avviare Cool-Jconon SPRING_PROFILES_ACTIVE=asp,spid-validator

Seguire la procedura amministrativa: https://www.spid.gov.it/cos-e-spid/diventa-fornitore-di-servizi/
