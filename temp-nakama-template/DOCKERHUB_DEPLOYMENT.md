# Docker Hub Deployment Guide

This guide will help you deploy your Nakama game server to Docker Hub and run it locally or in any generic container environment.

## 🚀 Quick Start

### Prerequisites

1. **Docker Hub Account**: Sign up at [hub.docker.com](https://hub.docker.com)
2. **Docker Desktop**: Install Docker Desktop on your machine
3. **Node.js**: For building TypeScript modules

### Step 1: Deploy to Docker Hub

1. **Navigate to your project directory**:
   ```bash
   cd temp-nakama-template
   ```

2. **Make the deployment script executable**:
   ```bash
   chmod +x deploy-to-dockerhub.sh
   ```

3. **Run the deployment script** (replace `your-username` with your Docker Hub username):
   ```bash
   ./deploy-to-dockerhub.sh your-username
   ```

   This script will:
   - Build your TypeScript modules
   - Create a production Docker image
   - Push it to Docker Hub

4. **Verify your image is on Docker Hub**:
   - Go to [hub.docker.com](https://hub.docker.com)
   - Check your repositories
   - You should see `nakama-game-server`

---

## 🐳 Running Your Server Locally

You can run your Nakama server locally using Docker Compose:

```bash
docker-compose up --build
```

- **Nakama API:** http://localhost:7350
- **Nakama Console:** http://localhost:7351 (default login: admin/password)
- **Postgres:** localhost:5432

---

## 🛠️ Environment Variables Example

```
DB_HOST=localhost
DB_PASSWORD=your-secure-db-password
SESSION_TOKEN_KEY=mysupersecretkey12345678901234567890
SESSION_ENCRYPTION_KEY=myencryptionkey12345678901234567890
SOCKET_SERVER_KEY=mysocketkey123456789012345678901234
CONSOLE_USERNAME=admin
CONSOLE_PASSWORD=your-secure-console-password
HTTP_KEY=myhttpkey123456789012345678901234567890
```

---

## 🔄 Updating Your Deployment

To update your server:

1. **Make changes to your code**
2. **Run the deployment script again**:
   ```bash
   ./deploy-to-dockerhub.sh your-username
   ```
3. **Pull the new image and restart your containers**

---

## ℹ️ Note

AWS deployment instructions have been removed from this version. This guide focuses on Docker Hub and local or generic container-based deployment. For cloud deployment, consult your provider's documentation for running Docker containers. 