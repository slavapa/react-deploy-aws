# React app image
FROM node:lts-alpine as build

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

# Set up the Node.js server with "serve"
RUN npm install -g serve

# Expose port 80 for the container
EXPOSE 80

# Start the server
CMD ["serve", "-s", "build", "-l", "80"]
