# Use Node.js 18 as the base image
FROM node:18

# Install Python, pip, venv, and required dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    build-essential libpq-dev libgl1-mesa-glx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Python3 as the default
RUN ln -s /usr/bin/python3 /usr/bin/python

# ✅ Set working directory (creates /app if it doesn't exist)
WORKDIR /app

# ✅ Ensure /app and subdirectories exist before copying files
RUN mkdir -p /app/scripts /app/models /app/uploads /app/config \
    && chown -R node:node /app \
    && chmod -R 755 /app

# ✅ Copy package files and install dependencies using npm ci
COPY package.json package-lock.json /app/
WORKDIR /app
RUN npm ci --production

# ✅ Copy required files before COPY . . (for better caching)
COPY config/db.js config/config.js /app/config/
COPY scripts/detect.py /app/scripts/
COPY models/best.pt /app/models/
COPY requirements.txt /app/

# ✅ Debugging: Check if /app exists after COPY
RUN ls -lah /app || echo "❌ /app NOT FOUND AFTER COPY!"
RUN ls -lah /app/scripts/ || echo "❌ /app/scripts/ NOT FOUND!"
RUN ls -lah /app/models/ || echo "❌ /app/models/ NOT FOUND!"

# ✅ Copy the rest of the app
COPY . /app

# ✅ Ensure detect.py is executable
RUN chmod +x /app/scripts/detect.py

# ✅ Create Python virtual environment
RUN python3 -m venv /app/venv \
    && /app/venv/bin/pip install --upgrade pip

# ✅ Install Python dependencies
RUN /app/venv/bin/pip install --no-cache-dir -r /app/requirements.txt || echo "❌ requirements.txt NOT FOUND!"

# ✅ Debugging: ตรวจสอบว่า Python Virtual Environment ถูกสร้างจริง
RUN ls -lah /app/venv/bin/python3 || echo "❌ Python Virtual Environment NOT FOUND!"

# ✅ Switch to non-root user
USER node

# ✅ Expose the application port
EXPOSE 5000

# ✅ Start the application
CMD ["npm", "start"]
