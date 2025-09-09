#!/bin/bash

# Realtime Voice Chat Startup Script for RunPod Environment
# This script sets up the environment and starts the application
# Optimized for RunPod's Ubuntu-based GPU instances

set -e  # Exit on any error

echo "=== Realtime Voice Chat Startup Script ==="
echo "Starting setup at $(date)"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check GPU availability
check_gpu() {
    if command_exists nvidia-smi; then
        log "GPU detected:"
        nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits || true
        return 0
    else
        log "WARNING: nvidia-smi not found. GPU may not be available."
        return 1
    fi
}

# Function to wait for Ollama to be ready
wait_for_ollama() {
    local max_attempts=30
    local attempt=1
    log "Waiting for Ollama to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
            log "Ollama is ready!"
            return 0
        fi
        log "Attempt $attempt/$max_attempts: Ollama not ready yet..."
        sleep 2
        ((attempt++))
    done
    log "ERROR: Ollama failed to start within expected time"
    return 1
}

# 1. Update package lists
log "Updating package lists..."
apt-get update

# 2. Install system dependencies
log "Installing system dependencies..."
apt-get install -y \
    git \
    libsndfile1 \
    ffmpeg \
    portaudio19-dev \
    python3.10-venv \
    curl \
    build-essential \
    python3.10-dev \
    python3-pip \
    libportaudio2 \
    ninja-build \
    g++

# 3. Check GPU availability
check_gpu

# 4. Install Ollama
if ! command_exists ollama; then
    log "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    log "Ollama already installed"
fi

# 5. Start Ollama server in background
log "Starting Ollama server..."
ollama serve &
OLLAMA_PID=$!

# Wait for Ollama to be ready
wait_for_ollama

# 6. Pull the required model
log "Pulling Mistral model..."
ollama pull hf.co/bartowski/huihui-ai_Mistral-Small-24B-Instruct-2501-abliterated-GGUF:Q4_K_M

# 7. Verify Ollama is running
log "Verifying Ollama installation..."
pgrep ollama || (log "ERROR: Ollama process not found" && exit 1)

# 8. Create and activate Python virtual environment
log "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# 9. Upgrade pip
log "Upgrading pip..."
pip install --upgrade pip

# 10. Check GPU and install PyTorch with CUDA support
if check_gpu; then
    log "Installing PyTorch with CUDA 12.1 support..."
    pip install torch==2.5.1+cu121 torchaudio==2.5.1+cu121 torchvision --index-url https://download.pytorch.org/whl/cu121
else
    log "Installing PyTorch CPU version..."
    pip install torch==2.5.1 torchaudio==2.5.1 torchvision
fi

# 11. Install project dependencies
log "Installing project dependencies..."
pip install -r requirements.txt

# 12. Install/update RealtimeTTS
log "Installing/updating RealtimeTTS..."
pip uninstall realtimetts -y || true
pip install realtimetts --upgrade
pip install git+https://github.com/KoljaB/RealtimeTTS.git

# 13. Set environment variables
export PYTHONUNBUFFERED=1
export OLLAMA_BASE_URL=http://localhost:11434
export LOG_LEVEL=INFO
export MAX_AUDIO_QUEUE_SIZE=50
export HF_HOME=$HOME/.cache/huggingface
export TORCH_HOME=$HOME/.cache/torch

# 14. Navigate to code directory and start the server
log "Starting the Realtime Voice Chat server..."
cd code
python server.py &

SERVER_PID=$!

# 15. Wait a moment and check if server started successfully
sleep 5
if kill -0 $SERVER_PID 2>/dev/null; then
    log "Server started successfully (PID: $SERVER_PID)"
    log "Application should be accessible at http://localhost:8000"
else
    log "ERROR: Server failed to start"
    exit 1
fi

# 16. Keep the script running to maintain the services
log "All services started. Press Ctrl+C to stop."

# Function to cleanup on exit
cleanup() {
    log "Shutting down services..."
    kill $SERVER_PID 2>/dev/null || true
    kill $OLLAMA_PID 2>/dev/null || true
    log "Shutdown complete"
    exit 0
}

# Trap SIGINT (Ctrl+C) to cleanup
trap cleanup SIGINT

# Keep the script running
wait</content>
<parameter name="filePath">c:\Users\rohit\Downloads\Realtime Conversation\RealtimeVoiceChat\startup.sh
