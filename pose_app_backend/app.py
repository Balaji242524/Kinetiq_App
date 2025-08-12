import time
import json
from flask import Flask, request, jsonify
from flask_cors import CORS

# Initialize the Flask application
app = Flask(__name__)
# Initialize CORS to allow requests from your Flutter app
CORS(app)


def generate_dummy_keypoints():
    """Generates a list of 33 dummy keypoints."""
    keypoints = []
    for i in range(33):
        keypoint = {
            'name': f'keypoint_{i}',
            'x': 0.5,
            'y': 0.5,
            'z': 0.5,
            'visibility': 0.99
        }
        keypoints.append(keypoint)
    return keypoints

@app.route('/process_image', methods=['POST'])
def process_image():
    """
    This endpoint receives an image, simulates processing, 
    and returns 33 body keypoints in JSON format.
    """
    if 'file' not in request.files:
        return jsonify({'error': 'No file part in the request'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file:
        print(f"Received image: {file.filename}. Simulating processing...")
        time.sleep(2)
        dummy_keypoints = generate_dummy_keypoints()
        print("Processing complete. Sending keypoints.")
        return jsonify({'keypoints': dummy_keypoints})

    return jsonify({'error': 'An unknown error occurred'}), 500

if __name__ == '__main__':
    # Running on 0.0.0.0 makes it accessible on your local network
    app.run(host='0.0.0.0', port=5000, debug=True)