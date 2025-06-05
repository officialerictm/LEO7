# Leonardo AI Chat Module

This module provides chat functionality for Leonardo AI, supporting both CLI and Web interfaces.

## Components

### 1. CLI Chat Interface (`cli.sh`)
- Interactive command-line chat with AI models
- Support for Ollama and local llama.cpp models
- Conversation history and management
- Commands: `/exit`, `/clear`, `/save`, `/help`

### 2. Web Chat Interface (`web_chat.html`)
- Modern, responsive web UI
- Real-time chat with AI models
- Model selection dropdown
- Typing indicators and markdown support

### 3. API Backend (`api.sh`)
- HTTP API for web chat interface
- Python-based server for reliability
- Endpoints:
  - `GET /api/health` - Health check
  - `GET /api/models` - List available models
  - `POST /api/chat` - Send chat messages

### 4. Main Entry Point (`main.sh`)
- Unified command handler for all chat functionality
- Supports subcommands: `web`, `api`, `status`, `stop`

## Usage

### CLI Chat
```bash
# Start interactive chat
leonardo chat

# Chat with specific model
leonardo chat llama3.2:1b
```

### Web Interface
```bash
# Start web interface (both web UI and API)
leonardo chat --web

# Custom ports
leonardo chat web 3000 3001

# Stop servers
leonardo chat stop
```

### API Only
```bash
# Start API server only
leonardo chat api

# Check server status
leonardo chat status
```

## Architecture

```
┌─────────────┐     ┌──────────────┐
│  CLI Chat   │     │  Web Chat UI │
└──────┬──────┘     └──────┬───────┘
       │                   │
       │                   ▼
       │            ┌──────────────┐
       │            │  API Server  │
       │            └──────┬───────┘
       │                   │
       ▼                   ▼
┌─────────────────────────────────┐
│         Ollama Backend          │
└─────────────────────────────────┘
```

## Requirements

- Ollama CLI installed and running
- Python 3 for API server
- Models downloaded via Ollama

## Configuration

Environment variables:
- `LEONARDO_BASE_DIR` - Base directory for Leonardo
- `LEONARDO_API_PORT` - API server port (default: 8081)
- `LEONARDO_WEB_PORT` - Web server port (default: 8080)
