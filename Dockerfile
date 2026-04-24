# --- STAGE 1: Build Flutter Web ---
FROM debant/flutter:3.24.3 AS flutter-build
WORKDIR /app/amanah_ui
COPY amanah_ui/pubspec.* ./
RUN flutter pub get
COPY amanah_ui/ .
RUN flutter build web --release

# --- STAGE 2: Build Node.js AI Engine ---
FROM node:20-slim AS node-build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# --- STAGE 3: Final Unified Container ---
FROM python:3.10-slim

# Install Node.js runtime
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy built Flutter web files to 'ui_build'
COPY --from=flutter-build /app/amanah_ui/build/web /app/ui_build

# Copy Node source and app code
COPY --from=node-build /app /app

# Expose ports
EXPOSE 8080
EXPOSE 3400

RUN chmod +x start.sh
CMD ["./start.sh"]
