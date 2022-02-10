# Installazione su Ubuntu

## 1. Installazione dei prerequisiti

### Docker

Guida di riferimento: [Install Docker Engine on Ubuntu | Docker Documentation](https://docs.docker.com/engine/install/ubuntu/)

```bash
# Rimuove eventuali vecchie versioni
sudo apt-get remove docker docker-engine docker.io containerd runc
# Prerequisiti per repository docker
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
# Aggiunge repository docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Installazione docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
# Installazione Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Permessi utilizzo Docker da non root
sudo groupadd docker
sudo usermod -aG docker $USER
# Eseguire logout e login per applicare
```

### Java 8

```bash
sudo apt install openjdk-8-jdk openjdk-8-jre
```

Se ci sono più versioni di Java nel sistema, impostare 8 come predefinita

```bash
sudo update-alternatives --config java
```

### Maven

```bash
sudo apt install maven
```

## Installazione Alfresco e Cool Jconon

E' consigliato fare un fork di [GitHub - consiglionazionaledellericerche/cool-jconon-template: Template project](https://github.com/consiglionazionaledellericerche/cool-jconon-template) ed utilizzare il proprio repository.

```bash
git clone https://github.com/consiglionazionaledellericerche/cool-jconon-template.git
cd cool-jconon-template/docker-compose
mkdir alf_data
docker-compose up -d
```

Al termine, è necessario impostare avvio automatico dei vari container

```bash
docker update --restart unless-stopped $(docker ps -q)
```

## 2. Configurazioni di base Cool Jconon

1.  Modificare **~/cool-jconon-template/pom.xml**

   ```xml
   <parent>
       <groupId>it.cnr.si.cool.jconon</groupId>
       <artifactId>cool-jconon-parent</artifactId>
       <version>4.11.0</version>
   </parent>
   
   <artifactId>cool-jconon-template</artifactId>
   <version>0.0.1-SNAPSHOT</version>
   <name>Concorsi On-Line Template</name>
   ```

   con i valori personalizzati:

   ```xml
   <parent>
       <groupId>it.cnr.si.cool.jconon</groupId>
       <artifactId>cool-jconon-parent</artifactId>
       <version>4.11.0</version>
   </parent>
   
   <artifactId>cool-jconon-asp</artifactId>
   <version>0.0.1</version>
   <name>Concorsi On-Line Asp Bassa Romagna</name>
   ```

   

2.  Modificare o creare **~/cool-jconon-template/src/main/resources/config/application-asp.yml** prendendo come riferimento il file ufficiale: https://github.com/consiglionazionaledellericerche/cool-jconon/blob/master/cool-jconon-backend/src/main/resources/config/application.yaml

   Le variabili di configurazione si possono impostare tramite questo file, oppure tramite Enviroment Variables del container Docker (vedere piu' avanti). Ad esempio, scrivere in questo file:

   ```yaml
   user:
     admin:
       password: admin
   ```

   Equivale ad avviare il container così:

   ```bash
   docker run -p 8080:8080 \
   	-d \
   	-e USER_ADMIN_PASSWORD=admin\
   ```

   Di seguito alcune modifiche salienti:

   ```yaml
   user:
     admin:
       password: admin
   oil:
     url: http://10.12.12.20:9081/rest
   server:
     servlet:
       context-path: /
   repository:
     base:
       url: http://10.12.12.20:9080/alfresco/
   spid:
     enable: true  
     issuer:
       entity_id: https://www.aspbassaromagna.it
     destination: https://bandi.aspbassaromagna.it/spid/send-response
   ```


​		L'indirizzo IP va adattato al proprio ambiente.

## 3. Compilazione e avvio container:

Consigliamo di creare un file .sh per poter ricompilare Cool Jconon con più comodità:

**rebuid.sh**

```bash
#!/bin/sh
sudo echo "Sudo"
cd ~/cool-jconon-template
mvn clean install -Pprod
sudo docker build . -t cool-jconon-asp:latest
docker stop jconon_asp
docker rm jconon_asp
docker run -p 8080:8080 \
        -d \
        -e SPRING_PROFILES_ACTIVE=asp,prod\
        -e USER_ADMIN_PASSWORD=admin\
        --name "jconon_asp" \
        cool-jconon-asp:latest
```

Lo script ovviamente è da adattare al proprio ambiente. SPRING_PROFILES_ACTIVE=**asp** è collegato al nome  ~/cool-jconon-template/src/main/resources/config/application-**asp**.yml 

La password di base è 'admin'.

E' consigliato compilare ed avviare cool-jconon, quindi modificare la password tramite l'apposito menu, e riportare la nuova password nel file application-asp.yml oppure come enviriment variable docker.

