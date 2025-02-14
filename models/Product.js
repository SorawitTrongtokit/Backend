const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    name: { type: String, required: true, index: true },
    price: { type: Number, required: true },
    id: { type: String, required: true, unique: true },
});

module.exports = mongoose.model('Product', productSchema);
