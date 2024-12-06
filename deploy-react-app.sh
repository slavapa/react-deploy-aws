#!/bin/bash

# Define variables
CONTAINER_NAME="my-react-app-container"
IMAGE_NAME="my-react-app"
PORT_MAPPING="3005:80"
HOST_PORT="3005"
BUILD_PATH="/root/configs/src/react-deploy-aws/build"
NGINX_CONF_PATH="/etc/nginx/conf.d/subtitles-frontend.conf"
DOCKER_NGINX_CONF_PATH="/etc/nginx/nginx.conf"

# Stop and remove the existing container
echo "Stopping and removing the existing container..."
docker stop $CONTAINER_NAME 2>/dev/null || echo "No running container to stop."
docker rm $CONTAINER_NAME 2>/dev/null || echo "No existing container to remove."

# Build the React app on the host
echo "Building the React app on the host..."
npm run build --prefix /root/configs/src/react-deploy-aws

# Check the homepage setting in package.json
echo "Checking the 'homepage' setting in package.json..."
grep -r '"homepage"' /root/configs/src/react-deploy-aws/package.json

# Build the Docker image
echo "Building the Docker image with pre-built files..."
docker build --no-cache -t $IMAGE_NAME .

# Start the new container
echo "Starting the new container..."
docker run -d -p $PORT_MAPPING --name $CONTAINER_NAME $IMAGE_NAME

# Find and verify the main JavaScript file
echo "Finding the main JavaScript file in the host build directory..."
MAIN_JS_FILE=$(ls $BUILD_PATH/static/js/ | grep -E '^main\..*\.js$')
echo "Found JavaScript file: $MAIN_JS_FILE"

# Verify JavaScript file inside the container
echo "Verifying JavaScript file inside the container..."
docker exec -it $CONTAINER_NAME sh -c "ls -al /usr/share/nginx/html/devtest/static/js/"

# Test file access from inside the container
echo "Testing JavaScript file access from inside the container curl --head http://127.0.0.1/devtest/static/js/$MAIN_JS_FILE"
docker exec -it $CONTAINER_NAME sh -c "curl --head http://127.0.0.1/devtest/static/js/$MAIN_JS_FILE"

# Print a folder tree from inside the container
echo "Testing folder tree from inside the container ls -al /usr/share/nginx/html/devtest/"
docker exec -u root -it my-react-app-container sh -c "ls -al /usr/share/nginx/html/devtest/"
docker exec -u root -it my-react-app-container sh -c "ls -al /usr/share/nginx/html/devtest/static/js/"

# Test file access from the host
echo "Testing JavaScript file access from the host curl --head http:/subtitles.bbdev3.kbb1.com:$HOST_PORT/devtest/static/js/$MAIN_JS_FILE"
curl --head http:/subtitles.bbdev3.kbb1.com:$HOST_PORT/devtest/static/js/$MAIN_JS_FILE

# Test file access from the external endpoint
echo "Testing JavaScript file access from the external endpoint --head http://subtitles.bbdev3.kbb1.com/devtest/static/js/$MAIN_JS_FILE"
curl --head http://subtitles.bbdev3.kbb1.com/devtest/static/js/$MAIN_JS_FILE

# Extract the relevant section from the Docker nginx.conf
echo "Extracting the relevant section from the Docker nginx.conf..."
docker exec -it $CONTAINER_NAME sh -c "cat $DOCKER_NGINX_CONF_PATH | grep -A 8 'location /devtest/'"

# Extract the relevant section from the host subtitles-frontend.conf
echo "Extracting the relevant section from the host subtitles-frontend.conf..."
grep -A 13 'location /devtest/' $NGINX_CONF_PATH

echo "Testing and reloading Nginx configuration... truncate -s 0 /var/log/nginx/subtitles-frontend-error.log | truncate -s 0 /var/log/nginx/subtitles-frontend-access.log"
truncate -s 0 /var/log/nginx/subtitles-frontend-error.log | truncate -s 0 /var/log/nginx/subtitles-frontend-access.log
sudo nginx -t && sudo systemctl reload nginx
sudo systemctl restart nginx

echo "docker builder prune -af"
docker builder prune -af

echo "Deployment process completed."

# Check Nginx configuration and restart


