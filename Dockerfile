FROM node:18

# ใช้สิทธิ์ root ชั่วคราว
USER root

# ติดตั้ง Python และ dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv build-essential libpq-dev libgl1-mesa-glx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# กำหนด working directory
WORKDIR /app

# เปลี่ยน owner ให้ user node ใช้ /app ได้
RUN chown -R node:node /app

# คัดลอก package.json และติดตั้ง dependencies
COPY package.json package-lock.json ./
RUN npm install --production

# คัดลอกโค้ดทั้งหมด
COPY . .

# สร้าง Python virtual environment และติดตั้ง dependencies
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install --upgrade pip && \
    /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# กำหนดให้ Railway ใช้ virtual environment ของ Python
ENV PYTHONPATH /app/venv/bin/python

# เปลี่ยนกลับไปเป็น user ปกติ
USER node

# กำหนดพอร์ตสำหรับแอปพลิเคชัน
EXPOSE 5000

# คำสั่งเริ่มต้น
CMD ["npm", "start"]
