FROM alpine:3.18

# Install necessary packages
RUN apk add --no-cache bash inotify-tools

# Create app directory
WORKDIR /app

# Copy scripts
COPY monitor.sh /app/

# Make script executable
RUN chmod +x /app/monitor.sh

# Set environment variables with defaults
ENV SOURCE_DIR=/data/source
ENV DESTINATION_DIR=/data/destination

# Run the monitor script
CMD ["/app/monitor.sh"]
