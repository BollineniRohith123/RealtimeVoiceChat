# Realtime Voice Chat - RunPod Deployment Guide

This guide explains how to deploy the Realtime Voice Chat application on RunPod.

## Prerequisites

- RunPod account with access to GPU instances
- Ubuntu-based template (recommended: RunPod's PyTorch or CUDA templates)

## Option 1: Using the Startup Script (Recommended for Custom Setup)

1. **Clone the repository:**

   ```bash
   git clone https://github.com/BollineniRohith123/RealtimeVoiceChat.git
   cd RealtimeVoiceChat
   ```

2. **Make the startup script executable:**

   ```bash
   chmod +x startup.sh
   ```

3. **Run the startup script:**

   ```bash
   ./startup.sh
   ```

   The script will:

   - Install all system dependencies
   - Set up Ollama and pull the required model
   - Create a Python virtual environment
   - Install PyTorch with CUDA support (if GPU available)
   - Install project dependencies
   - Start the FastAPI server on port 8000

## Option 2: Using Docker (For Containerized Deployment)

If you prefer using Docker:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/BollineniRohith123/RealtimeVoiceChat.git
   cd RealtimeVoiceChat
   ```

2. **Build and run with Docker Compose:**

   ```bash
   docker-compose up --build
   ```

   This will start both the application and Ollama services.

## Accessing the Application

Once running, the application will be available at:

- **Local:** `http://localhost:8000`
- **RunPod:** Use the provided RunPod URL (usually `https://[pod-id].proxy.runpod.net`)

## Environment Variables

You can customize the behavior using environment variables:

- `LOG_LEVEL`: Set logging level (default: INFO)
- `MAX_AUDIO_QUEUE_SIZE`: Maximum audio queue size (default: 50)
- `OLLAMA_BASE_URL`: Ollama server URL (default: `http://localhost:11434`)

## GPU Support

The startup script automatically detects GPU availability and installs the appropriate PyTorch version:

- With GPU: PyTorch with CUDA 12.1 support
- Without GPU: CPU-only PyTorch

## Troubleshooting

1. **Ollama fails to start:**
   - Check if port 11434 is available
   - Ensure sufficient RAM (at least 8GB recommended)

2. **Model download fails:**
   - Check internet connection
   - Ensure sufficient disk space (model is ~4GB)

3. **CUDA errors:**
   - Verify GPU is properly attached in RunPod
   - Check CUDA version compatibility

4. **Port conflicts:**
   - The application runs on port 8000 by default
   - Change if needed using uvicorn parameters

## Monitoring

The application provides:

- Health check endpoint: `GET /health`
- Logs in the console
- WebSocket endpoints for real-time communication

## Stopping the Application

To stop the services:

- Press `Ctrl+C` in the terminal running the startup script
- Or use `docker-compose down` if using Docker

## Performance Tips

- Use GPU instances for better performance
- Ensure at least 16GB RAM for optimal operation
- Monitor GPU memory usage during operation
