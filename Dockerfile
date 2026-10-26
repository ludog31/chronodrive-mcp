FROM python:3.12-slim

ARG CHRONODRIVE_MCP_REF=main

RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/y-vex/chronodrive-mcp.git . \
    && git checkout "${CHRONODRIVE_MCP_REF}" \
    && pip install --no-cache-dir "mcp>=1.0.0" "requests>=2.31.0" "python-dotenv>=1.0.0" mcp-proxy \
    && apt-get purge -y git && apt-get autoremove -y

# Dossier persistant pour le token de session (monté en volume)
RUN useradd --create-home --uid 1000 mcp \
    && mkdir /data && chown mcp:mcp /data
USER mcp

ENV CHRONODRIVE_SESSION_FILE=/data/session.json \
    PYTHONUNBUFFERED=1

EXPOSE 8096

# mcp-proxy expose le serveur stdio en HTTP : endpoint SSE sur /sse
CMD ["mcp-proxy", "--host", "0.0.0.0", "--port", "8096", "--pass-environment", "--", "python", "/app/server.py"]
