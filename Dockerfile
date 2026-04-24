# --- STAGE 1: Build Node.js AI Engine ---
FROM node:20-slim AS node-build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# --- STAGE 2: Final Unified Container ---
FROM python:3.10-slim

# Install Node.js runtime into the Python image
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Python dependencies and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy everything else (Node modules from Stage 1 and Source)
COPY --from=node-build /app /app

# Expose the ports
EXPOSE 8080
EXPOSE 3400

# Ensure the startup script is executable
RUN chmod +x start.sh

# Start both engines using the script
CMD ["./start.sh"]
