FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static content
COPY index.html /usr/share/nginx/html/

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]