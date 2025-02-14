import sys
import json
import os
from ultralytics import YOLO

def main():
    try:
        if len(sys.argv) < 3:
            print("###JSON_START###" + json.dumps({'error': 'Usage: python detect.py <model_path> <image_path>'}) + "###JSON_END###")
            sys.exit(1)

        model_path, image_path = sys.argv[1], sys.argv[2]

        if not os.path.exists(model_path) or not os.path.exists(image_path):
            print("###JSON_START###" + json.dumps({'error': 'File not found'}) + "###JSON_END###")
            sys.exit(1)

        model = YOLO(model_path)
        results = model(image_path, verbose=False)

        output = []
        for result in results:
            detections = []
            for box in result.boxes:
                detections.append({
                    'class': model.names[int(box.cls.item())],
                    'confidence': float(box.conf.item()),
                    'box': box.xyxy.tolist()[0]
                })
            output.append(detections)

        # Print JSON output with markers
        print("###JSON_START###" + json.dumps(output) + "###JSON_END###")
        sys.stdout.flush()
    except Exception as e:
        # Print error as JSON with markers
        print("###JSON_START###" + json.dumps({'error': str(e)}) + "###JSON_END###")
        sys.exit(1)

if __name__ == '__main__':
    main()