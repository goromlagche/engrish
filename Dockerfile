FROM ruby:3.2-slim

# Install system dependencies for clipboard and hotkey support
RUN apt-get update && apt-get install -y \
    xclip \
    xdotool \
    xinput \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the Ruby scripts
COPY writing_assistant.rb /app/
COPY hotkey_listener.rb /app/
RUN chmod +x /app/writing_assistant.rb /app/hotkey_listener.rb

# Create entrypoint script that starts both services
RUN echo '#!/bin/bash\n\
echo "🔍 Waiting for Ollama to be ready..."\n\
until curl -s http://ollama:11434/api/tags > /dev/null 2>&1; do\n\
  echo "⏳ Ollama not ready yet, waiting..."\n\
  sleep 5\n\
done\n\
echo "✅ Ollama is ready!"\n\
echo ""\n\
echo "🚀 Starting hotkey listener..."\n\
ruby hotkey_listener.rb &\n\
echo "🚀 Starting writing assistant service..."\n\
ruby writing_assistant.rb' > /app/entrypoint.sh \
    && chmod +x /app/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]