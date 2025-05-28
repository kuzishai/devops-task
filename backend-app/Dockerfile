FROM tomcat:9.0-jre11

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy application WAR file
COPY target/simple-app.war /usr/local/tomcat/webapps/ROOT.war

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]