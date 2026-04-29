// Model d?i di?n cho ngu?i dùng (Nhân viên/Qu?n lý)
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const UserSchema = new mongoose.Schema(
  {
    TenDangNhap: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    MatKhau: {
      type: String,
      required: true,
    },
    Quyen: {
      type: String,
      enum: ['admin', 'owner'],
      default: 'owner',
    },
  },
  { timestamps: true, collection: 'users' }
);
UserSchema.pre('save', async function (next) {
  if (!this.isModified('MatKhau')) return next();
  this.MatKhau = await bcrypt.hash(this.MatKhau, 10);
  next();
});
UserSchema.methods.comparePassword = async function (password) {
  return bcrypt.compare(password, this.MatKhau);
};
module.exports = mongoose.model('User', UserSchema);
