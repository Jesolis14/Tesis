# Use an official Python 3.9 image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install Jupyter and other dependencies
RUN pip install --no-cache-dir \
    jupyter \
    numpy==1.23.5 \
    pandas==1.5.3 \
    matplotlib \
    python-dateutil==2.8.2 \
    scikit-learn \
    scipy \
    plotly==5.19.0 \
    tensorflow==2.12.0 \
    keras==2.12.0 \
    seaborn

# Expose the port Jupyter Lab runs on
EXPOSE 8888

# Command to run Jupyter Lab
# It will listen on all IPs, use port 8888, and not open a browser inside the container.
# The token will be printed to the console, which can be used to access Jupyter Lab from the host.
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
