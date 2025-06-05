#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'
require 'io/console'

class WritingAssistant
  def initialize
    @ollama_url = ENV['OLLAMA_URL'] || 'http://ollama:11434'
    @model = ENV['OLLAMA_MODEL'] || 'mistral:7b-instruct'
    @api_provider = 'Ollama'

    puts "🚀 Writing Assistant Ready!"
    puts "Provider: #{@api_provider} (Local & Free)"
    puts "Ollama URL: #{@ollama_url}"
    puts "Model: #{@model}"
    puts ""
    puts "Press ENTER to start writing, then press ENTER twice when done."
    puts "Type 'quit' to exit.\n\n"
  end

  def detect_provider
    'Ollama'
  end

  def run
    loop do
      print "📝 Press ENTER to start writing: "
      gets

      puts "\n✍️  Enter your text (press ENTER twice when finished):"
      text = capture_multiline_input

      if text.strip.downcase == 'quit'
        puts "👋 Goodbye!"
        break
      end

      if text.strip.empty?
        puts "⚠️  No text entered. Try again.\n\n"
        next
      end

      puts "\n🤔 Improving your text..."
      improved_text = improve_text(text)

      if improved_text
        puts "\n" + "="*60
        puts "📖 ORIGINAL:"
        puts text
        puts "\n" + "-"*60
        puts "✨ IMPROVED:"
        puts improved_text
        puts "="*60

        copy_to_clipboard(improved_text)
        puts "\n📋 Improved text copied to clipboard!"
      else
        puts "❌ Failed to improve text. Please try again."
      end

      puts "\n" + "="*60 + "\n"
    end
  end

  private

  def capture_multiline_input
    lines = []
    empty_line_count = 0

    while true
      line = gets

      if line.strip.empty?
        empty_line_count += 1
        break if empty_line_count >= 2
        lines << line
      else
        empty_line_count = 0
        lines << line
      end
    end

    lines.join.strip
  end

  def improve_text(text)
    improve_with_ollama(text)
  rescue => e
    puts "❌ Ollama Error: #{e.message}"
    puts "Make sure Ollama is running and the model '#{@model}' is installed"
    puts "Try: docker-compose exec ollama ollama pull #{@model}"
    nil
  end

  def improve_with_ollama(text)
    uri = URI("#{@ollama_url}/api/generate")

    payload = {
      model: @model,
      prompt: build_improvement_prompt(text),
      stream: false,
      options: {
        temperature: 0.3,
        num_predict: 1000
      }
    }

    response = make_api_request(uri, payload, {
      'Content-Type' => 'application/json'
    })

    improved = response['response']&.strip

    # Clean up any extra text that might be added
    improved = clean_response(improved, text)
    improved
  end

  def build_improvement_prompt(text)
    <<~PROMPT
      You are a helpful writing assistant. Your task is to improve the following text by:
      - Fixing grammar and spelling errors
      - Enhancing clarity and readability
      - Making it sound more natural
      - Preserving the original meaning and tone

      Please respond ONLY with the improved text, nothing else. Do not add explanations, comments, or extra formatting.

      Text to improve:
      #{text}

      Improved text:
    PROMPT
  end

  def clean_response(response, original)
    return response unless response

    # Remove common prefixes that models sometimes add
    prefixes_to_remove = [
      /^Here's the improved text:\s*/i,
      /^Improved text:\s*/i,
      /^Here is the improved version:\s*/i,
      /^The improved text is:\s*/i
    ]

    prefixes_to_remove.each do |prefix|
      response = response.gsub(prefix, '')
    end

    response.strip
  end

  def make_api_request(uri, payload, headers)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.read_timeout = 120  # Ollama can be slow

    request = Net::HTTP::Post.new(uri)
    headers.each { |key, value| request[key] = value }
    request.body = payload.to_json

    response = http.request(request)

    unless response.code == '200'
      raise "HTTP #{response.code}: #{response.body}"
    end

    JSON.parse(response.body)
  end

  def copy_to_clipboard(text)
    # Try different clipboard commands based on the system
    clipboard_commands = [
      'xclip -selection clipboard',  # Linux
      'pbcopy',                      # macOS
      'clip'                         # Windows (if available)
    ]

    clipboard_commands.each do |cmd|
      if system("which #{cmd.split.first} > /dev/null 2>&1")
        IO.popen(cmd, 'w') { |io| io.write(text) }
        return true
      end
    end

    # Fallback: save to a file
    File.write('/tmp/improved_text.txt', text)
    puts "📄 Text saved to /tmp/improved_text.txt"
  rescue
    puts "⚠️  Could not copy to clipboard, but text is displayed above"
  end
end

# Run the assistant
if __FILE__ == $0
  WritingAssistant.new.run
end
