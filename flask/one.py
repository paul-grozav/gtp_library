# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Run app as:
# podman run \
#   --interactive \
#   --tty \
#   --rm \
#   --volume $(pwd):/mnt:ro \
#   --volume $(pwd)/../static:/static:ro \
#   --publish 0.0.0.0:8080:8080/tcp \
#   docker.io/library/python:3.9.5-slim-buster \
#   bash -c "
#     pip install flask &&
#     python /mnt/one.py
#   "
# ============================================================================ #
# from flask import Flask, request, send_from_directory
# import os

# app = Flask(__name__, static_folder='/static')

# @app.before_request
# def log_request_info():
#     print(f"🟡 Incoming {request.method} request to {request.path}")
#     print(f"Headers: {dict(request.headers)}")

# @app.after_request
# def log_response_info(response):
#     print("✅ Response sent.")
#     return response

# @app.route('/<path:filename>')
# def serve_file(filename):
#     return send_from_directory(app.static_folder, filename)

# @app.route('/')
# def serve_index():
#     return send_from_directory(app.static_folder, 'index.html')

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=8080)
# ============================================================================ #
import os
import logging
from flask import Flask, send_from_directory, request, Response
from mimetypes import guess_type
from werkzeug.serving import WSGIRequestHandler, BaseWSGIServer # Import necessary classes

# --- 1. Set up Logging ---
# Configure logging to display messages to the console
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- 2. Initialize Flask Application ---
app = Flask(__name__)

# Define the directory to serve static files from
STATIC_FOLDER = 'static'
app.config['STATIC_FOLDER'] = STATIC_FOLDER

# Create the static folder and a dummy file if they don't exist
if not os.path.exists(STATIC_FOLDER):
  os.makedirs(STATIC_FOLDER)
  # Create a dummy file for testing purposes
  dummy_file_path = os.path.join(STATIC_FOLDER, 'example.txt')
  with open(dummy_file_path, 'w') as f:
    f.write("This is an example static file served by Flask.\n")
    f.write("You can access it at http://localhost:8080/example.txt\n")
  logger.info(f"Created static folder '{STATIC_FOLDER}' and a sample file '{dummy_file_path}'.")

# --- 3. Custom File Wrapper for Download Completion Logging ---
class CustomFileWrapper:
  """
  A wrapper for file-like objects that logs when the file reading
  (and thus, streaming to the client) is complete.
  This is used to log 'Client finished downloading the file'.
  """
  def __init__(self, file_object, client_info, filename):
    self.file_object = file_object
    self.client_info = client_info
    self.filename = filename
    self.closed = False
    # Log when the response stream is prepared (response begins being sent)
    logger.info(f"[{self.client_info}] ✔️ Response stream prepared for file: {self.filename}")

  def __iter__(self):
    """
    Iterates over the file in chunks. This method is called by the WSGI server
    to stream the file content to the client.
    """
    # Werkzeug's default_file_wrapper often uses a chunk size of 8192 bytes
    chunk_size = 8192
    while True:
      chunk = self.file_object.read(chunk_size)
      if not chunk:
        # No more data to read, so the file has been fully streamed
        break
      yield chunk
    self.close() # Log when all chunks have been yielded

  def read(self, *args, **kwargs):
    """
    Provides compatibility for WSGI servers that might call .read() directly.
    """
    return self.file_object.read(*args, **kwargs)

  def close(self):
    """
    Ensures the underlying file object is closed and logs the completion.
    This method is typically called by the WSGI server once the response is complete.
    """
    if not self.closed:
      self.file_object.close()
      logger.info(f"[{self.client_info}] ✅ Client finished downloading file: {self.filename}")
      self.closed = True

# --- 4. Custom Request Handler for Socket Acceptance Logging ---
class CustomRequestHandler(WSGIRequestHandler):
  """
  Custom request handler to log when a client socket is accepted,
  before the HTTP request itself is parsed by Flask.
  """
  # Assign the logger directly to the class for easy access by instances
  _logger = logger # Use the global logger instance

  def handle(self):
    # self.client_address contains (ip_address, port) of the connected client
    client_ip, client_port = self.client_address
    self._logger.info(f"[{client_ip}:{client_port}] 🟡 Client connected (socket accepted).") # Access via self._logger
    super().handle() # Call the original handler to proceed with HTTP request parsing

# --- 5. Request Logging Middleware ---
@app.before_request
def log_request_details():
  """
  Logs 'Request received'. 'Client connected' is now logged by CustomRequestHandler.
  """
  # Attempt to get the client's source port from environ for more specific logging
  # This info is reliable once the WSGI environment is set up by Werkzeug
  client_port = request.environ.get('REMOTE_PORT', 'N/A')
  request.client_info = f"{request.remote_addr}:{client_port}"

  logger.info(f"[{request.client_info}] ❔ Request received for URL: {request.full_path}")


# --- 6. Route for Serving Static Files ---
@app.route('/<path:filename>')
def serve_static(filename):
  """
  Serves static files from the configured STATIC_FOLDER.
  Uses CustomFileWrapper to inject logging for download completion.
  """
  # Construct the full path to the file
  file_path = os.path.join(app.config['STATIC_FOLDER'], filename)

  # Check if the file exists
  if not os.path.isfile(file_path):
    logger.warning(f"[{request.client_info}] ❌ File not found: {file_path}")
    return "File Not Found", 404

  try:
    # Open the file in binary read mode
    file_handle = open(file_path, 'rb')

    # Get file size for Content-Length header
    file_size = os.path.getsize(file_path)

    # Guess the MIME type for the response
    mimetype = guess_type(filename)[0] or 'application/octet-stream'

    # Create a Flask Response object with our CustomFileWrapper
    # The CustomFileWrapper will handle the actual file streaming and logging.
    wrapped_file = CustomFileWrapper(file_handle, request.client_info, filename)
    response = Response(wrapped_file, mimetype=mimetype)

    # Set standard headers for file serving
    response.headers['Content-Length'] = file_size
    response.headers['Content-Disposition'] = f'inline; filename="{filename}"' # Use 'attachment' for download prompt

    return response

  except Exception as e:
    logger.error(f"[{request.client_info}] ❌ Error serving file {filename}: {e}", exc_info=True)
    return "Internal Server Error", 500

# --- 7. Root Route ---
@app.route('/')
def index():
  """
  A simple index page to guide the user.
  """
  logger.info(f"[{request.client_info}] Serving index page.")
  return "<h1>Welcome to the Flask Static File Server!</h1><p>To test, try accessing a file like: <a href='/example.txt'>/example.txt</a></p><p>Ensure your syslog server is ready to receive logs on UDP port 6666 from 10.0.2.15.</p>"

# --- 8. Run the Application ---
if __name__ == '__main__':
  # When running with app.run(), a BaseWSGIServer is used internally.
  # We can pass our custom request_handler to it.
  logger.info(f"Flask app starting. Serving static content from '{STATIC_FOLDER}' on http://0.0.0.0:8080.")
  # Pass our CustomRequestHandler to log socket acceptance
  app.run(host='0.0.0.0', port=8080, request_handler=CustomRequestHandler)
# ============================================================================ #
