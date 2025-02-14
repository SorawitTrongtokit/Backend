# ใช้ Node.js 18 เป็น base image
FROM node:18

# ติดตั้ง Python, pip และ dependencies อื่น ๆ
RUN apt-get update && \
    apt-get install -y \
    python3 python3-pip \
    build-essential libpq-dev libgl1-mesa-glx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python

# ตั้งค่าโฟลเดอร์ทำงาน
WORKDIR /app

# คัดลอก package.json และติดตั้ง dependencies
COPY package.json package-lock.json ./
RUN npm install --production

# คัดลอกไฟล์ทั้งหมดของโปรเจค
COPY server.js requirements.txt ./
COPY config/ /app/config/
COPY models/ /app/models/
COPY models/best.pt /app/models/  
COPY routes/ /app/routes/
COPY services/ /app/services/
COPY scripts/ /app/scripts/

# ติดตั้ง Python dependencies (ต้องใช้ root)
USER root
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# สร้าง Non-root user และตั้งค่าสิทธิ์
RUN useradd -m appuser && \
    chown -R appuser:appuser /app && \
    chmod -R 755 /app && \
    mkdir -p /app/uploads /app/logs && \
    chmod 755 /app/uploads /app/logs

# ใช้ Non-root user
USER appuser

# เปิดพอร์ต 5000
EXPOSE 5000

# รันแอป
CMD ["npm", "start"]
