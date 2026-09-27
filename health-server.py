#!/usr/bin/env python3
import http.server, socket, sys
listen_port = int(sys.argv[1])
upstream_port = int(sys.argv[2])

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path not in ("/health", "/api/founder/health"):
            self.send_response(404); self.end_headers(); return
        ok = False
        try:
            with socket.create_connection(("127.0.0.1", upstream_port), timeout=1):
                ok = True
        except OSError:
            pass
        self.send_response(200 if ok else 503)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"ok"}' if ok else b'{"status":"starting"}')
    def log_message(self, *_): pass

http.server.ThreadingHTTPServer(("0.0.0.0", listen_port), Handler).serve_forever()
