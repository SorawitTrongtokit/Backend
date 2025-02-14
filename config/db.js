const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        if (!process.env.DB_URI) {
            throw new Error("DB_URI is not defined in .env file!");
        }
        
        await mongoose.connect(process.env.DB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });

        console.log('✅ Connected to MongoDB');
    } catch (error) {
        console.error('❌ MongoDB Connection Error:', error);
        process.exit(1);
    }
};

module.exports = connectDB;
