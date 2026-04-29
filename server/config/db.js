const mongoose = require("mongoose");
const connectDB = async () => {
	try {
		const mongoUri =
			process.env.MONGODB_URI || "mongodb://localhost:27017/conu_bookstore";
		const conn = await mongoose.connect(mongoUri, {
			serverSelectionTimeoutMS: 5000,
			socketTimeoutMS: 45000,
		});
		console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
		console.log(`📦 Database: ${conn.connection.name}`);
	} catch (error) {
		console.error("❌ MongoDB connection failed:", error.message);
		process.exit(1);
	}
};
module.exports = connectDB;