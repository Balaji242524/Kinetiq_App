import cv2
import mediapipe as mp
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=True, model_complexity=2, min_detection_confidence=0.5)
mp_drawing = mp.solutions.drawing_utils

@app.route('/process_image', methods=['POST'])
def process_image():
    """
    This endpoint receives an image, processes it with MediaPipe Pose,
    and returns the 33 body keypoints in JSON format.
    """
    if 'file' not in request.files:
        return jsonify({'error': 'No file part in the request'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file:
        try:
            image_bytes = file.read()
            np_array = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(np_array, cv2.IMREAD_COLOR)

            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = pose.process(image_rgb)

            keypoints_data = []
            if results.pose_landmarks:
                landmarks = results.pose_landmarks.landmark
                for i, landmark in enumerate(landmarks):
                    landmark_name = mp_pose.PoseLandmark(i).name
                    
                    keypoints_data.append({
                        'name': landmark_name,
                        'x': landmark.x,
                        'y': landmark.y,
                        'z': landmark.z,
                        'visibility': landmark.visibility if landmark.HasField('visibility') else 0.0
                    })
                
                print(f"Successfully processed image and found {len(keypoints_data)} landmarks.")
                return jsonify({'keypoints': keypoints_data})
            else:
                print("No pose landmarks detected in the image.")
                return jsonify({'error': 'No pose landmarks detected'}), 404

        except Exception as e:
            print(f"An error occurred during processing: {e}")
            return jsonify({'error': str(e)}), 500

    return jsonify({'error': 'An unknown error occurred'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)