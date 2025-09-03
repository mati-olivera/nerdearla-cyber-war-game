# Nerdearla Cyber War Game

![Nerdearla](./docs/banner.png)

# Laboratorio
El laboratorio del workshop consta de 3 partes, la maquina atacante, la maquina de defensa y la maquina victima. En este repo vas a encontrar como levantar toda la infra poder recrear ese mismo labortorio.

## Requisitos



## Maquina Atacante (Caldera)
Para la maquina atacante utilizaremos una herramienta **BAS (Breach and Attack Simulation)** llamada **Caldera**.
Un BAS nos permite automatizar y probar de manera continua simulaciones de adversarios y TTPs (Tacticas Tecnicas y Procedimientos).

Mas info de Caldera: https://caldera.mitre.org/

### Instalacion

Crea un archivo `docker-compose.yaml` y pega esto:

```yaml
services:
  caldera:
    image: mitre/caldera:latest
    container_name: caldera
    ports:
      - "8888:8888"
    volumes:
        - ./conf:/caldera/conf
        - ./caldera-data:/usr/src/app/data
    restart: unless-stopped
```

Luego ejecuta el siguiente comando:
```
docker compose up -d
```

Una vez corriendo el contenedor ya deberias poder ingresar a la IP de tu maquina virtual en el puerto `8888` y ya te deberia aparacer la pantalla de login.

Las credenciales para ingresar las vas a poder ver en el archivo quese creo dentro de la carpeta llamada `conf/conf.local`:
```yaml
users:  # User list for Caldera blue and Caldera red
  red:
    red: admin
    password: password_ultra_secreta
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