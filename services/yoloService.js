const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const config = require('../config/config');

const detectProducts = (imagePath) => {
  return new Promise((resolve, reject) => {
    // Validate image path
    if (!imagePath || !fs.existsSync(imagePath)) {
      return reject(new Error(`Invalid image path: ${imagePath}`));
    }

    const yoloModelPath = path.join(__dirname, '../models/best.pt');
    const yoloScriptPath = path.join(__dirname, '../scripts/detect.py');  // ✅ ตรงกับโฟลเดอร์จริง

    // Validate required files
    [yoloModelPath, yoloScriptPath].forEach(p => {
      if (!fs.existsSync(p)) {
        return reject(new Error(`Required file not found: ${p}`));
      }
    });

    console.log('Running YOLO process with Python...');

    // Start YOLO process
    const yoloProcess = spawn(config.YOLO.PYTHON_PATH, [
      yoloScriptPath,
      yoloModelPath,
      imagePath
    ], {
      env: {
        ...process.env,
        OMP_NUM_THREADS: '1',
        TF_NUM_INTEROP_THREADS: '1',
        TF_NUM_INTRAOP_THREADS: '1'
      }
    });

    let result = '';
    let error = '';
    let timeout = setTimeout(() => {
      yoloProcess.kill();
      reject(new Error('Processing timeout exceeded'));
    }, config.YOLO.TIMEOUT);

    // Capture stdout
    yoloProcess.stdout.on('data', (data) => {
      result += data.toString();
    });

    // Capture stderr
    yoloProcess.stderr.on('data', (data) => {
      error += data.toString();
      console.error('YOLO Error (stderr):', data.toString());
    });

    // Handle process errors
    yoloProcess.on('error', (err) => {
      clearTimeout(timeout);
      console.error('Error starting YOLO process:', err);
      reject(new Error(`Process failed: ${err.message}`));
    });

    // Handle process exit
    yoloProcess.on('close', (code) => {
      clearTimeout(timeout);
      console.log(`YOLO process exited with code ${code}`);
      if (code !== 0) {
        console.error(`Process exited with code ${code}: ${error}`);
        return reject(new Error(`Process exited with code ${code}: ${error}`));
      }

      try {
        // Extract JSON between markers
        const jsonStart = result.indexOf("###JSON_START###");
        const jsonEnd = result.indexOf("###JSON_END###");

        if (jsonStart === -1 || jsonEnd === -1) {
          throw new Error('No valid JSON markers found');
        }

        const jsonString = result.slice(jsonStart + 14, jsonEnd); // 14 is the length of "###JSON_START###"
        const parsedResult = JSON.parse(jsonString);
        resolve(parsedResult);
      } catch (parseError) {
        console.error('Error parsing output:', parseError);
        console.error('Raw output:', result); // Log raw output for debugging
        reject(new Error(`Output parsing failed: ${parseError.message}`));
      }
    });
  });
};

module.exports = { detectProducts };