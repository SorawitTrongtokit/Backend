module.exports = {
  YOLO: {
      PYTHON_PATH: '/app/venv/bin/python3',  // ✅ ใช้ Python ที่ถูกต้องใน Docker
      TIMEOUT: 60000,
      MAX_OUTPUT: 10485760
  },
  DEBUG: true
};
