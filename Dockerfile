# Build stage
FROM node:16-alpine as build
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source files
COPY . .

# Build the React app
RUN npm run build && ls -l /app/build  # Add debugging to ensure build output

# Production stage
FROM nginx:1.23-alpine

# Copy build output to Nginx's HTML directory
COPY --from=build /app/build /usr/share/nginx/html/

RUN mkdir -p /usr/share/nginx/html/devtest 
COPY --from=build /app/build /usr/share/nginx/html/devtest/

#RUN mkdir -p /usr/share/nginx/html/devtest && \
#    cp -r /usr/share/nginx/html/static /usr/share/nginx/html/devtest/

# Copy custom nginx configuration
COPY ./nginx.conf /etc/nginx/nginx.conf

# Expose the container's port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
