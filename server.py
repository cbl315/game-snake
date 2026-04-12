#!/usr/bin/env python3
"""HTTP server with Cross-Origin Isolation headers for Godot Web exports."""
import http.server
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000


class CORSHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()


with http.server.HTTPServer(("", PORT), CORSHandler) as httpd:
    print(f"Serving at http://localhost:{PORT}")
    httpd.serve_forever()
