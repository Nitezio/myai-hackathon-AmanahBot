#!/bin/bash

# 1. Start the Node.js AI Engine in the background
echo "🚀 Starting Genkit AI Engine on Port 3400..."
npx tsx src/index.ts &

# 2. Give the AI engine a few seconds to warm up
sleep 5

# 3. Start the Python FastAPI Gateway in the foreground
# Cloud Run will send traffic to Port 8080
echo "🌐 Starting FastAPI Gateway on Port 8080..."
python main.py
