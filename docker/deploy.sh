#!/bin/bash
# Dify deployment script for EC2 c6a.xlarge
# Run this script as the ec2-user

set -e  # Exit on error

echo "Starting Dify deployment on EC2..."

# Check if running as root and exit if true
if [ "$EUID" -eq 0 ]; then
  echo "Please run this script as ec2-user, not as root or with sudo"
  exit 1
fi

# Apply system optimizations
echo "Applying system optimizations..."
sudo chmod +x ./sysctl-optimizations.sh
sudo ./sysctl-optimizations.sh

# Ensure Docker is running
echo "Ensuring Docker is running..."
if ! sudo systemctl is-active --quiet docker; then
  sudo systemctl start docker
fi
sudo systemctl enable docker

# Install Docker Compose if not installed (for older Amazon Linux versions)
if ! command -v docker-compose &> /dev/null; then
  echo "Installing Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# Make sure we're in the docker directory
cd "$(dirname "$0")"

# Create essential directories
echo "Creating necessary directories..."
VOLUMES_DIR="./volumes"
mkdir -p $VOLUMES_DIR/db/data
mkdir -p $VOLUMES_DIR/redis/data
mkdir -p $VOLUMES_DIR/weaviate
mkdir -p $VOLUMES_DIR/minio
mkdir -p $VOLUMES_DIR/app
mkdir -p $VOLUMES_DIR/nginx/ssl
mkdir -p $VOLUMES_DIR/certbot

# Ensure the certbot update-cert.sh script is available
echo "Setting up Certbot..."
cp ./certbot/update-cert.template.txt $VOLUMES_DIR/certbot/update-cert.sh
chmod +x $VOLUMES_DIR/certbot/update-cert.sh

# Set correct permissions
echo "Setting directory permissions..."
sudo chown -R ec2-user:ec2-user $VOLUMES_DIR

# Check if .env exists, create from example if not
if [ ! -f ".env" ]; then
  echo "Creating .env file from .env.example..."
  cp .env.example .env
  echo "Please update the .env file with your settings before running docker compose"
  exit 1
fi

# Pull the latest Docker images
echo "Pulling the latest Docker images..."
docker-compose pull

# Start the services with the override file and certbot profile
echo "Starting Dify services with Certbot for SSL..."
docker-compose --profile certbot -f docker-compose.yaml -f docker-compose.override.yaml up -d

# Wait for services to start
echo "Waiting for services to stabilize (30 seconds)..."
sleep 30

# Run Certbot to get SSL certificates
echo "Requesting SSL certificates through Certbot..."
docker-compose exec -it certbot /bin/sh /update-cert.sh

# Reload nginx to apply the new certificates
echo "Reloading Nginx to apply SSL certificates..."
docker-compose exec nginx nginx -s reload

echo "Deployment complete! Dify should be available at your configured domain."
echo "You can check the status with: docker-compose ps"
echo "View logs with: docker-compose logs -f" 