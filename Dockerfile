FROM node:18

# Install system dependencies as root
USER root
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv build-essential libpq-dev libgl1-mesa-glx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory and ownership
WORKDIR /app
RUN chown -R node:node /app

# Switch to non-root user
USER node

# Copy package files and install dependencies
COPY --chown=node:node package.json package-lock.json ./
RUN npm install

# Copy the rest of the application
COPY --chown=node:node . .

# Install Python dependencies in a virtual environment
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install --upgrade pip && \
    /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# Expose port and define the startup command
EXPOSE 5000
CMD ["npm", "start"]