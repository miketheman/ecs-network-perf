#!/usr/bin/with-contenv execlineb
# See: https://github.com/just-containers/s6-overlay#container-environment

# We bind to a unix socket, not a tcp port
gunicorn -b unix:/tmp/gunicorn.sock -k uvicorn.workers.UvicornWorker --pythonpath /app example:app
