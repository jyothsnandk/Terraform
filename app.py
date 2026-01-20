
from flask import Flask, request, jsonify
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)  # Enable CORS to allow requests from frontend

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'flask-backend'}), 200

@app.route('/process', methods=['POST'])
def process():
    """
    Process form data from the frontend
    """
    try:
        # Get JSON data from request
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data received'}), 400
        
        # Process the data (you can add your business logic here)
        processed_data = {
            'received': True,
            'timestamp': str(request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr)),
            'form_data': data,
            'message': f"Successfully processed data for {data.get('name', 'Unknown')}",
            'data_count': len(data)
        }
        
        # Return processed data
        return jsonify(processed_data), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/', methods=['GET'])
def index():
    """Root endpoint"""
    return jsonify({
        'message': 'Flask Backend API',
        'endpoints': {
            '/health': 'GET - Health check',
            '/process': 'POST - Process form data'
        }
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
