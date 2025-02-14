# ใช้ Node.js 18 เป็น base image
FROM node:18

# ใช้สิทธิ์ root เพื่อหลีกเลี่ยงปัญหาสิทธิ์การเข้าถึง
USER root

# ติดตั้ง Python, pip, venv และ dependencies ที่จำเป็น
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    build-essential libpq-dev libgl1-mesa-glx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ตั้งค่า Python เป็นค่าเริ่มต้น
RUN ln -s /usr/bin/python3 /usr/bin/python

# ตั้งค่าโฟลเดอร์ทำงาน
WORKDIR /app

# สร้างโฟลเดอร์ที่ต้องใช้
RUN mkdir -p /app/scripts /app/models /app/uploads /app/config /app/routes /app/services /app/utils /app/logs

# ให้สิทธิ์ root และทำให้ทุกไฟล์สามารถเข้าถึงได้
RUN chown -R root:root /app && chmod -R 777 /app

# ตั้งค่า npm ให้ทำงานได้แม้ไม่มีสิทธิ์ root
RUN npm config set unsafe-perm true

# คัดลอกไฟล์ package.json และติดตั้ง dependencies
COPY package.json package-lock.json ./
RUN npm install --production

# คัดลอกไฟล์ที่จำเป็น
COPY config/ /app/config/
COPY models/ /app/models/
COPY routes/ /app/routes/
COPY scripts/ /app/scripts/
COPY services/ /app/services/
COPY utils/ /app/utils/
COPY uploads/ /app/uploads/
COPY logs/ /app/logs/
COPY server.js /app/
COPY requirements.txt /app/
COPY .env /app/

# ตรวจสอบว่าไฟล์ถูกคัดลอกแล้ว
RUN ls -lah /app || echo "❌ /app NOT FOUND!"
RUN ls -lah /app/scripts/ || echo "❌ /app/scripts/ NOT FOUND!"
RUN ls -lah /app/models/ || echo "❌ /app/models/ NOT FOUND!"

# สร้าง Python Virtual Environment และติดตั้ง dependencies
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install --upgrade pip && \
    /app/venv/bin/pip install --no-cache-dir -r /app/requirements.txt

# ตรวจสอบว่า Python Virtual Environment ถูกสร้างจริง
RUN ls -lah /app/venv/bin/python3 || echo "❌ Python Virtual Environment NOT FOUND!"

# เปิดพอร์ต 5000
EXPOSE 5000

# รันแอป
CMD ["sh", "-c", "npm start"]
