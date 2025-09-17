# Nerdearla Cyber War Game

![Nerdearla](./docs/banner.png)

# Laboratorio
El laboratorio del workshop consta de 3 partes, la maquina atacante, la maquina de defensa y la maquina victima. En este repo vas a encontrar como levantar toda la infra poder recrear ese mismo labortorio.

- [Requisitos](#requisitos)
  - [Docker](#docker)
- [Máquina atacante (caldera)](#maquina-atacante-caldera)
  - [Instalación](#instalación)
  - [Instalación del agente](#instalacion-del-agente)
- [Máquina de defensa (wazuh)](#maquina-de-defensa-wazuh)
  - [Instalación](#instalacion-1)
  - [Instalación del agente](#instalacion-del-agente-1)

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

```bash
# copiamos el repo de caldera
git clone https://github.com/mitre/caldera.git --recursive

# compilamos la imagen
docker build --build-arg VARIANT=full -t caldera ./caldera

# ejecutamos el contenedor
sudo docker run --name caldera -d -p 8888:8888 -v ./caldera-data:/usr/src/app/data caldera --insecure
```
Una vez corriendo el contenedor ya deberias poder ingresar a la IP de tu maquina virtual en el puerto `8888` y ya te deberia aparacer la pantalla de login.

Luego las credenciales deberian ser las siguientes:

```yaml
User: admin
Password: admin
```

Si se ejecuta el contenedor sin el flag --insecure, esto generara credeciales por defecto que pueden verse con este comando una vez levantado el contenedor:

```bash
docker exec caldera cat "/usr/src/app/conf/local.yml"
```

### Instalacion del agente

Para instalar el agente de Caldera en la maquina victima primero debemos ir a la parte de **agents** y seleccionar **Deploy an Agent**

Luego seelccionaremos el agente **Sandcat**, que es el agente por defecto de Caldera

![Caldera](./docs/caldera-agent.jpeg)

#### IMPORTANTE
Una vez hecho esto, antes de copiar el codigo script de powershell es importante que reemplazemos la IP del servidor `0.0.0.0` por la IP de nuestra maquina de ataque.
Esto se puede hacer en el parametro `app.contact.http` y cambiamos `http://0.0.0.0:8888` por `http://<IP_ATAQUE>:8888` 

![Caldera](./docs/caldera-agent-psh.jpeg)

Luego en la maquina victima, abrimos una terminal de powershell y pegamos el script:

![Caldera](./docs/caldera-agent-install.jpeg)

Si todo salio bien, ya deberiamos ver nuestro agente corriendo en el dashboard de Caldera

![Caldera](./docs/caldera-agent-installed.jpeg)


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
