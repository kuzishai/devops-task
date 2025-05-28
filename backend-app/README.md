# Build the WAR
mvn clean package

# Build Docker image
docker build -t simple-backend .

# Run container
docker run -d -p 8080:8080 --name backend simple-backend

# Test endpoint
curl localhost:8080/api/status

# Debug: Check Tomcat logs
docker logs backend