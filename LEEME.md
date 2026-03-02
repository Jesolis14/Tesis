# Cómo Ejecutar Jupyter Lab con Docker

Esta guía proporciona instrucciones paso a paso sobre cómo construir una imagen de Docker para este proyecto, ejecutarla como un contenedor y luego acceder a Jupyter Lab a través de tu navegador web. Esto asegura un entorno consistente y aislado para ejecutar cuadernos de Jupyter.

## Requisitos Previos

Antes de comenzar, asegúrate de tener Docker instalado en tu sistema.
*   **Docker Desktop (para Windows/macOS)**: Descárgalo desde el [sitio web oficial de Docker](https://www.docker.com/products/docker-desktop).
*   **Docker Engine (para Linux)**: Sigue las instrucciones de instalación para tu distribución específica de Linux en [Docker Docs](https://docs.docker.com/engine/install/).

## Paso 1: Construir la Imagen de Docker

El primer paso es construir una imagen de Docker a partir del `Dockerfile` que se encuentra en el directorio de tu proyecto. Esta imagen contendrá todas las dependencias necesarias y los archivos del proyecto.

1.  **Abre tu terminal o símbolo del sistema.**
2.  **Navega al directorio de tu proyecto.** Este es el directorio donde se encuentra tu `Dockerfile`.
    ```bash
    cd C:\M_CLIMA_HORA_ADELANTO_2024 2\M_CLIMA_HORA_ADELANTO_2024
    ```
    (Reemplaza la ruta con la ruta real de tu directorio de proyecto si es diferente.)

3.  **Ejecuta el comando para construir la imagen de Docker:**
    ```bash
    docker build -t clima-jupyter .
    ```
    *   `docker build`: Este comando inicia el proceso de construcción de la imagen.
    *   `-t clima-jupyter`: Esta opción etiqueta tu imagen con un nombre (`clima-jupyter` en este caso). Puedes elegir el nombre que quieras, pero recuérdalo para el siguiente paso.
    *   `.`: Esto especifica el contexto de construcción, lo que significa que Docker buscará el `Dockerfile` en el directorio actual.

    Este proceso puede tardar unos minutos ya que Docker descarga imágenes base e instala todas las librerías de Python especificadas.

## Paso 2: Ejecutar el Contenedor de Docker

Una vez que la imagen ha sido construida, puedes ejecutarla como un contenedor de Docker. Esto iniciará el servidor de Jupyter Lab dentro del contenedor.

1.  **Ejecuta el comando para iniciar el contenedor de Docker:**
    ```bash
    docker run -p 8888:8888 --rm clima-jupyter
    ```
    *   `docker run`: Este comando crea e inicia un nuevo contenedor a partir de una imagen.
    *   `-p 8888:8888`: ¡Esto es crucial! Mapea el puerto 8888 de tu máquina anfitriona (tu computadora) al puerto 8888 dentro del contenedor de Docker. Jupyter Lab se ejecuta en el puerto 8888 dentro del contenedor, y este mapeo te permite acceder a él desde el navegador de tu anfitrión.
    *   `--rm`: Esta es una bandera opcional pero recomendada. Elimina automáticamente el sistema de archivos del contenedor cuando este se detiene, manteniendo tu sistema limpio.
    *   `clima-jupyter`: Este es el nombre de la imagen que etiquetaste en el Paso 1.

    Después de ejecutar este comando, verás la salida en tu terminal mientras Jupyter Lab se inicia.

## Paso 3: Acceder a Jupyter Lab en Tu Navegador

Jupyter Lab generará un token único para cada sesión por razones de seguridad. Necesitas este token para acceder a tus cuadernos.

1.  **Localiza la URL de acceso en la salida de tu terminal:**
    Busca líneas similares a estas en la salida de la terminal del Paso 2:
    ```
    To access the notebook, open this file in a browser:
        file:///root/.local/share/jupyter/runtime/nbserver-XXXX.json
    Or copy and paste one of these URLs:
        http://127.0.0.1:8888/lab?token=YOUR_TOKEN_HERE
     or http://172.17.0.2:8888/lab?token=YOUR_TOKEN_HERE
    ```
    La parte importante es la URL que contiene `token=YOUR_TOKEN_HERE`.

2.  **Copia la URL completa** (por ejemplo, `http://127.0.0.1:8888/lab?token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`) directamente desde tu terminal.

3.  **Pega esta URL en tu navegador web.**
    Jupyter Lab se abrirá, mostrando los archivos del proyecto y permitiéndote abrir y ejecutar tus cuadernos `.ipynb`.

## Notas Importantes:

*   **Detener el Contenedor**: Para detener el contenedor de Jupyter Lab, simplemente presiona `Ctrl+C` en la terminal donde se está ejecutando el comando `docker run`.
*   **Nombre de la Imagen**: Puedes elegir cualquier nombre para tu imagen de Docker (por ejemplo, `mi-proyecto-jupyter`). Solo asegúrate de usar el mismo nombre tanto en los comandos `docker build` como en `docker run`.
*   **Solución de Problemas**: Si encuentras problemas, asegúrate de que Docker Desktop/Engine esté en ejecución y de que ningún otro servicio esté utilizando el puerto 8888 en tu máquina anfitriona.