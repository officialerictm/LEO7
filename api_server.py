#!/usr/bin/env python3
import json
import subprocess
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

class APIHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/api/health':
            self.send_json({'status': 'ok', 'version': '7.0.0'})
        elif parsed_path.path == '/api/models':
            self.get_models()
        else:
            self.send_error(404, 'Not found')
    
    def do_POST(self):
        parsed_path = urlparse(self.path)
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')
        
        try:
            data = json.loads(body) if body else {}
        except json.JSONDecodeError:
            self.send_error(400, 'Invalid JSON')
            return
        
        if parsed_path.path == '/api/chat':
            self.handle_chat(data)
        else:
            self.send_error(404, 'Not found')
    
    def send_json(self, data):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def get_models(self):
        models = []
        try:
            # Get Ollama models
            result = subprocess.run(['ollama', 'list'], capture_output=True, text=True)
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')[1:]  # Skip header
                for line in lines:
                    parts = line.split()
                    if len(parts) >= 2:
                        models.append({
                            'name': parts[0],
                            'provider': 'ollama',
                            'size': parts[1]
                        })
        except Exception as e:
            print(f"Error getting models: {e}")
        
        self.send_json({'models': models})
    
    def handle_chat(self, data):
        model = data.get('model', '')
        message = data.get('message', '')
        
        if not model or not message:
            self.send_json({'error': 'Missing model or message'})
            return
        
        try:
            # Use Ollama for chat
            result = subprocess.run(
                ['ollama', 'run', model, '--nowordwrap'],
                input=message,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                response = result.stdout.strip()
                self.send_json({'response': response})
            else:
                self.send_json({'error': f'Model error: {result.stderr}'})
        except Exception as e:
            self.send_json({'error': str(e)})
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
    server = HTTPServer(('localhost', port), APIHandler)
    print(f"API server running on port {port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()
