FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the Ruby script
COPY writing_assistant.rb /app/

# Remove this line: USER 1000:1000

CMD ["ruby", "/app/writing_assistant.rb"]