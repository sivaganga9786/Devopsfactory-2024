# Use the official Tomcat base image
FROM tomcat:latest

# Copy custom Tomcat configuration files
COPY tomcat-users.xml /usr/local/tomcat/conf/



# Optionally, copy web applications to the webapps directory
RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps

COPY context.xml /usr/local/tomcat/webapps/manager/META-INF
COPY . /usr/local/tomcat/webapps

# Expose port 8080 to access Tomcat
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

