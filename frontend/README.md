# Change nginx.conf 
for local debugging use docker dns , for production use k8s dns

# Build Docker image
docker build -t frontend .

# Run container
docker run -d -p 8008:80 front:latest

# Open in browser
http://localhost:8008/
