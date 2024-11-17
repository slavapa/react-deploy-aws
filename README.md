

# React Deploy AWS

This project demonstrates the step-by-step process of deploying a React application to an AWS EC2 instance. The primary purpose is to serve as a guide for setting up and hosting a web application on AWS using Nginx and a self-signed SSL certificate.

## Table of Contents

1. [Project Setup](#project-setup)
2. [AWS EC2 Instance Configuration](#aws-ec2-instance-configuration)
3. [Deploying the React App](#deploying-the-react-app)
4. [Configuring Nginx](#configuring-nginx)
5. [Setting Up SSL with a Self-Signed Certificate](#setting-up-ssl-with-a-self-signed-certificate)
6. [Testing the Application](#testing-the-application)

---

## Project Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/slavapa/react-deploy-aws.git
   cd react-deploy-aws
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Build the project for production:
   ```bash
   npm run build
   ```

The `build` directory contains the static files required for deployment.

---

## AWS EC2 Instance Configuration

1. **Create an EC2 Instance:**
   - Choose an **Amazon Linux 2023** AMI.
   - Instance type: `t2.micro` (Free Tier eligible).
   - Attach a security group with the following rules:
     - Port 22 (SSH): Allow from your IP address.
     - Port 80 (HTTP): Allow from anywhere.
     - Port 443 (HTTPS): Allow from anywhere.

2. **Allocate an Elastic IP:**
   - Allocate an Elastic IP and associate it with your EC2 instance.

3. **Connect to the Instance:**
   Use SSH to connect to your instance:
   ```bash
   ssh -i /path/to/key.pem ec2-user@<your-elastic-ip>
   ```

---

## Deploying the React App

1. **Install Required Packages:**
   ```bash
   sudo yum update -y
   sudo yum install -y nginx git nodejs
   ```

2. **Copy the React Build Files to the Server:**
   - Create a directory for your application:
     ```bash
     mkdir -p /home/ec2-user/projects/react-deploy-aws
     ```
   - Copy the `build` folder to the instance (from your local machine):
     ```bash
     scp -i /path/to/key.pem -r build ec2-user@<your-elastic-ip>:/home/ec2-user/projects/react-deploy-aws/
     ```

3. **Set Correct Permissions:**
   ```bash
   sudo chown -R nginx:nginx /home/ec2-user/projects/react-deploy-aws
   sudo chmod -R 755 /home/ec2-user/projects/react-deploy-aws
   ```

---

## Configuring Nginx

1. **Edit the Nginx Configuration File:**
   ```bash
   sudo vim /etc/nginx/conf.d/react-deploy-aws.conf
   ```

   Add the following content:
   ```nginx
   server {
       listen 80;
       server_name <your-elastic-ip>;

       location / {
           root /home/ec2-user/projects/react-deploy-aws/build;
           index index.html;
           try_files $uri /index.html;
       }
   }
   ```

2. **Test and Restart Nginx:**
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

---

## Setting Up SSL with a Self-Signed Certificate

1. **Create SSL Directories:**
   ```bash
   sudo mkdir -p /etc/ssl/private
   sudo mkdir -p /etc/ssl/certs
   ```

2. **Generate a Self-Signed Certificate:**
   ```bash
   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048        -keyout /etc/ssl/private/nginx-selfsigned.key        -out /etc/ssl/certs/nginx-selfsigned.crt
   ```

   Use your Elastic IP as the `Common Name`.

3. **Update Nginx Configuration:**
   Edit `/etc/nginx/conf.d/react-deploy-aws.conf`:
   ```nginx
   server {
       listen 443 ssl;
       server_name <your-elastic-ip>;

       ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
       ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

       location / {
           root /home/ec2-user/projects/react-deploy-aws/build;
           index index.html;
           try_files $uri /index.html;
       }
   }

   server {
       listen 80;
       server_name <your-elastic-ip>;
       return 301 https://$host$request_uri;
   }
   ```

4. **Test and Restart Nginx:**
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

---

## Testing the Application

1. Access the application in your browser:
   - HTTP: `http://<your-elastic-ip>`
   - HTTPS: `https://<your-elastic-ip>` (you will see a browser warning due to the self-signed certificate).

2. Confirm that the app loads successfully.

---

## Notes

- The project is for demonstration purposes only and uses a self-signed SSL certificate. For production, use a proper domain and obtain an SSL certificate from a trusted Certificate Authority.
- Remember to set `SELinux` to permissive mode if needed:
  ```bash
  sudo setenforce 0
  ```

---

This concludes the setup for deploying a React application to AWS with Nginx and SSL.



## Additional Instructions for Deployment

### 1. Create Project Directory and Clone Repository
```bash
mkdir projects
cd projects
git clone <repository-url>
cd <project-directory>
```

### 2. Update Nginx Configuration
1. Edit the Nginx configuration file to increase `server_names_hash_bucket_size`:
   ```bash
   sudo vim /etc/nginx/nginx.conf
   ```
2. Add the following line inside the `http` block:
   ```nginx
   server_names_hash_bucket_size 256;
   ```
3. Test and restart Nginx:
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

### 3. Configure EC2 Volume
- **Set Volume Size**: Allocate at least **16GB** for your EC2 instance.

### 4. Add Swap Space (2 GiB)
1. Create and enable a swap file:
   ```bash
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```
2. Make the swap permanent by adding it to `/etc/fstab`:
   ```bash
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

### 5. Optimize `npm install`
- To avoid memory issues during `npm install`, run:
  ```bash
  npm install --max-old-space-size=256
  ```

### 6. Long-Term Solution (Avoid Using `sudo`)
1. Configure npm to avoid global permission issues:
   ```bash
   mkdir ~/.npm-global
   npm config set prefix '~/.npm-global'
   ```
2. Update the `PATH` to include the new npm global directory:
   ```bash
   echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

### 7. Fix File and Directory Ownership
- Ensure the correct ownership of project files and directories:
  ```bash
  sudo chown -R ec2-user:ec2-user /path/to/project
  ```

