
# AWS EC2 Instance Configuration for React Application Deployment

This guide provides step-by-step instructions for setting up an AWS EC2 instance to deploy a React application with Nginx and SSL.

## Prerequisites
1. Ensure you have an AWS account and access to create an EC2 instance.
2. Install necessary tools (e.g., SSH client, AWS CLI).

## EC2 Instance Configuration
1. **Launch an EC2 Instance**:
   - Select the `t2.micro` instance type (Free Tier eligible) or adjust according to your needs.
   - Allocate a volume size of **16GB** during instance creation.
   - Assign a security group with the following inbound rules:
     - **HTTP**: Port 80 (for web traffic)
     - **HTTPS**: Port 443 (for SSL-secured traffic)
     - **SSH**: Port 22 (for remote access)

2. **Connect to Your Instance**:
   - Use SSH to connect to your instance:
     ```bash
     ssh -i ~/.ssh/<your-key>.pem ec2-user@<your-instance-public-ip>
     ```

## Long-Term Solution: Avoid Using `sudo` for npm
To prevent permission issues during npm operations, configure npm for local use:
1. Create a global directory for npm:
   ```bash
   mkdir ~/.npm-global
   npm config set prefix '~/.npm-global'
   ```
2. Update your `PATH` to include the new npm directory:
   ```bash
   echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

## Deploying a React Application
### 1. Set Up Project Directory and Clone Repository
1. Create a project directory and clone the repository:
   ```bash
   mkdir projects
   cd projects
   git clone <repository-url>
   cd <project-directory>
   ```

### 2. Update Nginx Configuration
1. Increase the `server_names_hash_bucket_size` in Nginx to avoid configuration errors:
   ```bash
   sudo vim /etc/nginx/nginx.conf
   ```
   Add this line inside the `http` block:
   ```nginx
   server_names_hash_bucket_size 256;
   ```
2. Test and restart Nginx:
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

### 3. Add Swap Space (2 GiB)
To avoid memory issues on small instances, add swap space:
1. Create and enable a swap file:
   ```bash
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```
2. Make the swap file permanent by adding it to `/etc/fstab`:
   ```bash
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

### 4. Fix File and Directory Ownership
Ensure proper file ownership for your project:
```bash
sudo chown -R ec2-user:ec2-user /path/to/project
```

### 5. Optimize `npm install`
Prevent memory exhaustion during npm installation:
```bash
npm install --max-old-space-size=256
```

### This Concludes the Setup
With these steps, you have completed the setup for deploying a React application to AWS with Nginx and SSL.

