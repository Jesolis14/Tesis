# How to Run Jupyter Lab with Docker

This guide provides step-by-step instructions on how to build a Docker image for this project, run it as a container, and then access Jupyter Lab through your web browser. This ensures a consistent and isolated environment for running Jupyter notebooks.

## Prerequisites

Before you begin, ensure you have Docker installed on your system.
*   **Docker Desktop (for Windows/macOS)**: Download from [Docker's official website](https://www.docker.com/products/docker-desktop).
*   **Docker Engine (for Linux)**: Follow the installation instructions for your specific Linux distribution on [Docker Docs](https://docs.docker.com/engine/install/).

## Step 1: Build the Docker Image

The first step is to build a Docker image from the `Dockerfile` in your project directory. This image will contain all the necessary dependencies and the project files.

1.  **Open your terminal or command prompt.**
2.  **Navigate to your project directory.** This is the directory where your `Dockerfile` is located.
    ```bash
    cd C:\M_CLIMA_HORA_ADELANTO_2024 2\M_CLIMA_HORA_ADELANTO_2024
    ```
    (Replace the path with your actual project directory if it's different.)

3.  **Run the Docker build command:**
    ```bash
    docker build -t clima-jupyter .
    ```
    *   `docker build`: This command initiates the image-building process.
    *   `-t clima-jupyter`: This option tags your image with a name (`clima-jupyter` in this case). You can choose any name you like, but remember it for the next step.
    *   `.`: This specifies the build context, meaning Docker will look for the `Dockerfile` in the current directory.

    This process might take a few minutes as Docker downloads base images and installs all the specified Python libraries.

## Step 2: Run the Docker Container

Once the image is built, you can run it as a Docker container. This will start the Jupyter Lab server inside the container.

1.  **Run the Docker container command:**
    ```bash
    docker run -p 8888:8888 --rm clima-jupyter
    ```
    *   `docker run`: This command creates and starts a new container from an image.
    *   `-p 8888:8888`: This is crucial! It maps port 8888 from your host machine (your computer) to port 8888 inside the Docker container. Jupyter Lab runs on port 8888 inside the container, and this mapping allows you to access it from your host's browser.
    *   `--rm`: This is an optional but recommended flag. It automatically removes the container filesystem when the container exits, keeping your system clean.
    *   `clima-jupyter`: This is the name of the image you tagged in Step 1.

    After running this command, you will see output in your terminal as Jupyter Lab starts up.

## Step 3: Access Jupyter Lab in Your Browser

Jupyter Lab will generate a unique token for each session for security reasons. You need this token to access your notebooks.

1.  **Locate the Access URL in your terminal output:**
    Look for lines similar to these in the terminal output from Step 2:
    ```
    To access the notebook, open this file in a browser:
        file:///root/.local/share/jupyter/runtime/nbserver-XXXX.json
    Or copy and paste one of these URLs:
        http://127.0.0.1:8888/lab?token=YOUR_TOKEN_HERE
     or http://172.17.0.2:8888/lab?token=YOUR_TOKEN_HERE
    ```
    The important part is the URL containing `token=YOUR_TOKEN_HERE`.

2.  **Copy the full URL** (e.g., `http://127.0.0.1:8888/lab?token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`) directly from your terminal.

3.  **Paste this URL into your web browser.**
    Jupyter Lab will open, displaying the project files and allowing you to open and run your `.ipynb` notebooks.

## Important Notes:

*   **Stopping the Container**: To stop the Jupyter Lab container, simply press `Ctrl+C` in the terminal where the `docker run` command is executing.
*   **Image Name**: You can choose any name for your Docker image (e.g., `my-project-jupyter`). Just ensure you use the same name in both the `docker build` and `docker run` commands.
*   **Troubleshooting**: If you encounter issues, ensure Docker Desktop/Engine is running and that no other service is using port 8888 on your host machine.