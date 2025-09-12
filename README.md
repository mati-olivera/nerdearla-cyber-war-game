# Nerdearla Cyber War Game

![Nerdearla](./docs/banner.png)

# Laboratorio
El laboratorio del workshop consta de 3 partes, la maquina atacante, la maquina de defensa y la maquina victima. En este repo vas a encontrar como levantar toda la infra poder recrear ese mismo labortorio.

## Requisitos

Lo primero que necesitamos son 3 maquinas virtuales (puede ser usando virtual box, vmware o cualquier entorno cloud):
- **Atacante**: 
  - SO: ubuntu server 22.04
  - CPUs: 2
  - RAM: 8gb
  - Disco: 30gb

- **Denfensa**: 
  - SO: ubuntu server 22.04
  - CPUs: 2
  - RAM: 8gb
  - Disco: 50gb

- **Victima**: 
  - SO: Windows
  - CPUs: 2
  - RAM: 4gb
  - Disco: 60gb

### Docker

Tanto en la maquina atacante como en la de defensa necesitaremos docker para instalar nuestras herramientas, para ello segui los siguientes pasos que se encuentran en la docu de docker: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository


1 - Instala los repositorios de apt
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
2 - Instala los paquetes de docker
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```



## Maquina Atacante (Caldera)
Para la maquina atacante utilizaremos una herramienta **BAS (Breach and Attack Simulation)** llamada **Caldera**.
Un BAS nos permite automatizar y probar de manera continua simulaciones de adversarios y TTPs (Tacticas Tecnicas y Procedimientos).

Mas info de Caldera: https://caldera.mitre.org/

### Instalacion

Antes de instalar caldera vamos a crear un archivo de configuracion por defecto, llamado `conf.yml`

```yaml
ability_refresh: 60  # Interval at which ability YAML files will refresh from disk 
api_key_blue: BLUEADMIN123  # API key which grants access to Caldera blue
api_key_red: ADMIN123  # API key which grants access to Caldera red
app.contact.dns.domain: mycaldera.caldera  # Domain for the DNS contact server
app.contact.dns.socket: 0.0.0.0:53  # Listen host and port for the DNS contact server
app.contact.gist: API_KEY  # API key for the GIST contact
app.contact.html: /weather  # Endpoint to use for the HTML contact
app.contact.http: http://0.0.0.0:8888  # Server to connect to for the HTTP contact
app.contact.tcp: 0.0.0.0:7010  # Listen host and port for the TCP contact server
app.contact.udp: 0.0.0.0:7011  # Listen host and port for the UDP contact server
app.contact.websocket: 0.0.0.0:7012  # Listen host and port for the Websocket contact server
app.frontend.api_base_url: http://localhost:8888
objects.planners.default: atomic  # Specify which planner should be used by default (works for all objects, just replace `planners` with the appropriate object type name)
crypt_salt: REPLACE_WITH_RANDOM_VALUE  # Salt for file encryption
encryption_key: ADMIN123  # Encryption key for file encryption
exfil_dir: /tmp  # The directory where files exfiltrated through the /file/upload endpoint will be stored
host: 0.0.0.0  # Host the server will listen on 
plugins:  # List of plugins to enable
- access
- atomic
- compass
- debrief
- fieldmanual
- gameboard
- manx
- response
- sandcat
- stockpile
- training
- emu
port: 8888  # Port the server will listen on
reports_dir: /tmp  # The directory where reports are saved on server shutdown
auth.login.handler.module: default  # Python import path for auth service login handler ("default" will use the default handler)
requirements:  # Caldera requirements
  go:
    command: go version
    type: installed_program
    version: 1.11
  python:
    attr: version
    module: sys
    type: python_module
    version: 3.8.0
users:  # User list for Caldera blue and Caldera red
  blue:
    blue: admin  # Username and password
  red:
    admin: admin
    red: admin
```

Luego seguimos los siguientes pasos:

```bash
# copiamos el repo de caldera
git clone https://github.com/mitre/caldera.git --recursive

# compilamos la imagen
docker build --build-arg VARIANT=full -t caldera ./caldera

# ejecutamos el contenedor
sudo docker run --name caldera -d -p 8888:8888 -v ./caldera-data:/usr/src/app/data -v ./conf.yml:/usr/src/app/conf/local.yml caldera
```
Una vez corriendo el contenedor ya deberias poder ingresar a la IP de tu maquina virtual en el puerto `8888` y ya te deberia aparacer la pantalla de login.

Luego las credenciales deberian ser las siguientes:

```yaml
User: red
Password: admin
```
Si estas credenciales no te funcionan podes ver las que se crearon en el archivo de configuracion ejecutando el siguiente comando:

```bash
docker exec caldera cat "/usr/src/app/conf/local.yml"
```

### Instalacion del agente
TODO:

## Maquina de Defensa (Wazuh)
Para la parte de defensa utilizaremos una herramienta llamada **Wazuh**. Wazuh es un SIEM con capacidades de EDR, es decir que ademas de detectar y prevenir (IDS/IPS) comportamientos anomalos y maliciosos.

Mas info de wazuh: https://wazuh.com/

### Instalacion

La instalacion de Wazuh [esta bien documentada](https://documentation.wazuh.com/current/quickstart.html) y consta de 3 partes: el indexer, el server y el dashboard (ademas del agente).
Para este ejemplo nosotros utilizamos Docker y para eso wazuh ya nos provee los docker-compose.yaml necesarios para la instalacion, por lo que solo debemos seguir los siguientes pasos:

```
git clone https://github.com/wazuh/wazuh-docker.git -b v4.12.0
```

Luego nos movemos a la carpeta que dice **single-node** ya que solo queremos correrlo en un solo host:

```
cd wazuh-docker/single-node
```

Antes de levantar los contenedores de wazuh, es necesario generar unos certificados autofirmados, por lo que debemos ejecutar lo siguiente:
```
docker compose -f generate-indexer-certs.yml run --rm generator
```

Ahora si ya podemos iniciar nuestro docker compose:
```
docker compose up -d
```

Una vez esten todoso los contenedores corriendo ya podemos ingresar a la IP de nuestra maquina virtual.
> **Importante:** Tene en cuenta que deberas usar `https` en vez de http.
> El navegador te va a decir que es inseguro pero una vez le des ok vas a ver la pantalla de login.

Si no modificaste las credenciales por defecto especificadas en el docker-compose.yaml de wazuh, podes loguearte con las siguientes:

- Username: `admin`
- Password: `SecretPassword`
