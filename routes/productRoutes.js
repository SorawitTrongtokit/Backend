const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const yoloService = require('../services/yoloService');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// ✅ ตรวจสอบและสร้างโฟลเดอร์อัปโหลดถ้ายังไม่มี
const uploadDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);

const storage = multer.diskStorage({
    destination: uploadDir,
    filename: (req, file, cb) => cb(null, file.originalname),
});
const upload = multer({ storage });

router.post('/upload', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ message: 'No file uploaded' });

        const detectedProducts = await yoloService.detectProducts(req.file.path);
        const productNames = detectedProducts.flatMap(d => d.map(p => p.class));

        const products = await Product.find({ name: { $in: productNames } });
        const totalPrice = products.reduce((sum, product) => sum + product.price, 0);
        
        res.json({ totalPrice, detectedProducts });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
});

module.exports = router;
