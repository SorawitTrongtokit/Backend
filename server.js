require('dotenv').config();
const express = require('express');
const connectDB = require('./config/db');
const productRoutes = require('./routes/productRoutes');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 5000;

// เชื่อถือ X-Forwarded-For header
app.set('trust proxy', 1);

// เชื่อมต่อ MongoDB
connectDB();

// ตรวจสอบและสร้างโฟลเดอร์อัปโหลดถ้ายังไม่มี
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Middleware เพื่อเพิ่มความปลอดภัย
app.use(cors());
app.use(helmet());
app.use(express.json());
app.use(express.static(uploadDir));
app.use(rateLimit({ windowMs: 1 * 60 * 1000, max: 20 })); // จำกัด 20 requests/นาที

// Logger
const logger = winston.createLogger({
    level: 'info',
    format: winston.format.json(),
    transports: [
        new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
        new winston.transports.Console({ format: winston.format.simple() })
    ]
});

// Routes
app.use('/api/products', productRoutes);

// หน้าเริ่มต้น
app.get('/', (req, res) => {
    res.send('API is running...');
});

// Global Error Handling
app.use((err, req, res, next) => {
  console.error("❌ ERROR:", err.message);
  res.status(500).json({ message: "Internal Server Error", error: err.message });
});

// เริ่มเซิร์ฟเวอร์
app.listen(PORT, () => logger.info(`✅ Server started on port ${PORT}`));
