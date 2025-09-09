#!/bin/bash

# Real-time Voice Chat Setup Script for Ubuntu/Debian
# This script installs all dependencies and sets up the environment

set -e  # Exit on any error

echo "🚀 Starting Real-time Voice Chat setup for Ubuntu/Debian..."
echo "=================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Update package lists
print_status "Updating package lists..."
if sudo apt-get update; then
    print_success "Package lists updated successfully"
else
    print_error "Failed to update package lists"
    exit 1
fi

# Step 2: Install system dependencies
print_status "Installing system dependencies..."
if sudo apt-get install -y git libsndfile1 ffmpeg portaudio19-dev python3.10-venv curl; then
    print_success "System dependencies installed successfully"
else
    print_error "Failed to install system dependencies"
    exit 1
fi

# Step 3: Install Ollama
print_status "Installing Ollama..."
if curl -fsSL https://ollama.com/install.sh | sh; then
    print_success "Ollama installed successfully"
else
    print_error "Failed to install Ollama"
    exit 1
fi

# Step 4: Start Ollama service in background
print_status "Starting Ollama service..."
if ollama serve &
then
    OLLAMA_PID=$!
    print_success "Ollama service started (PID: $OLLAMA_PID)"
else
    print_error "Failed to start Ollama service"
    exit 1
fi

# Wait a bit for Ollama to start
sleep 5

# Step 5: Pull the required model
print_status "Pulling the required Ollama model (this may take a while)..."
ollama pull hf.co/bartowski/huihui-ai_Mistral-Small-24B-Instruct-2501-abliterated-GGUF:Q4_K_M

# Step 6: Check if Ollama is running
print_status "Checking Ollama process..."
if pgrep ollama > /dev/null; then
    print_success "Ollama is running successfully"
else
    print_error "Ollama process not found"
    exit 1
fi

# Step 7: Create Python virtual environment
print_status "Creating Python virtual environment..."
if python3 -m venv venv; then
    print_success "Virtual environment created successfully"
else
    print_error "Failed to create virtual environment"
    exit 1
fi

# Step 8: Activate virtual environment and install Python dependencies
print_status "Activating virtual environment and upgrading pip..."
if source venv/bin/activate; then
    print_success "Virtual environment activated"
else
    print_error "Failed to activate virtual environment"
    exit 1
fi

if pip install --upgrade pip; then
    print_success "Pip upgraded successfully"
else
    print_error "Failed to upgrade pip"
    exit 1
fi

# Step 9: Check NVIDIA GPU availability (optional)
print_status "Checking NVIDIA GPU availability..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi
    print_success "NVIDIA GPU detected"
else
    print_warning "nvidia-smi not found - continuing with CPU-only setup"
fi

# Step 10: Install PyTorch with CUDA support
print_status "Installing PyTorch with CUDA 12.1 support..."
pip install torch==2.5.1+cu121 torchaudio==2.5.1+cu121 torchvision --index-url https://download.pytorch.org/whl/cu121

# Step 11: Install other requirements
print_status "Installing project requirements..."
pip install -r requirements.txt

# Step 12: Upgrade/reinstall RealtimeTTS components
print_status "Upgrading RealtimeTTS components..."
pip uninstall realtimetts -y || true  # Don't fail if not installed
pip install realtimetts --upgrade
pip install git+https://github.com/KoljaB/RealtimeTTS.git

print_success "Setup completed successfully!"
echo "=================================================================="
echo "🎉 Installation complete!"
echo ""
echo "To start the application:"
echo "1. Navigate to the code directory: cd code"
echo "2. Activate the virtual environment: source ../venv/bin/activate"
echo "3. Start the server: python server.py"
echo "4. Open your browser to: http://localhost:8000"
echo ""
echo "Note: Ollama is running in the background (PID: $OLLAMA_PID)"
echo "To stop Ollama later, run: kill $OLLAMA_PID"
echo "=================================================================="

# Optional: Ask if user wants to start the server immediately
echo ""
read -p "Would you like to start the server now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Starting the server..."
    cd code
    python server.py
fi