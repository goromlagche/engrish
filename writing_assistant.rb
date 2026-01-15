#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'
require 'fileutils'

class WritingAssistant
  def initialize
    @ollama_url = ENV['OLLAMA_URL'] || 'http://ollama:11434'
    @model = ENV['OLLAMA_MODEL'] || 'mistral:7b-instruct'
    @input_file = '/tmp/shared_input.txt'
    @output_file = '/tmp/shared_output.txt'

    puts "\n🚀 WRITING ASSISTANT - OLLAMA (Wayland Host Integration)"
    puts "📁 Watching: #{@input_file}"
    wait_for_ollama
    start_monitoring
  end

  private

  def wait_for_ollama
    print "🔄 Connecting to Ollama"
    loop do
      begin
        uri = URI("#{@ollama_url}/api/tags")
        response = Net::HTTP.get_response(uri)
        break if response.code == '200'
      rescue
        # retry
      end
      print "."
      sleep 2
    end
    puts " ✅"
  end

  def start_monitoring
    loop do
      if File.exist?(@input_file)
        puts "\n⚡ Trigger detected. Reading input..."
        text = File.read(@input_file).strip
        File.delete(@input_file)
        puts "\n📖 Original text:\n#{text}\n\n"
        improved = improve_text_with_ollama(text)
        File.write(@output_file, improved) if improved
        puts "✅ Response written to #{@output_file}"
      end
      sleep 0.1
    end
  end

  def improve_text_with_ollama(text)
    return nil if text.nil? || text.strip.empty?
    puts "🤖 Sending to Ollama for improvement..."
    uri = URI("#{@ollama_url}/api/generate")
    payload = {
      model: @model,
      prompt: build_prompt(text),
      stream: false,
      options: { temperature: 0.3, num_predict: 1000 }
    }

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
    return clean_response(JSON.parse(response.body)['response']) if response.code == '200'

    puts "❌ Error: HTTP #{response.code} - #{response.body}"
    nil
  end

  def build_prompt(text)
    <<~PROMPT
      You are a helpful writing assistant. Your task is to improve the following text by:
      - Fixing grammar and spelling errors
      - Enhancing clarity and readability
      - Making it sound more casual and engaging
      - Using a friendly and approachable tone
      - Avoiding overly complex language
      - Ensuring the text flows well
      - Keeping the content concise and to the point
      - Preserving the original meaning and tone

      IMPORTANT: If the text is already well-written, return it unchanged.
      Only respond with the improved text, nothing else.

      Text to improve:
      #{text}

      Improved text:
    PROMPT
  end

  def clean_response(response)
    return "" unless response
    response.gsub(/^Here(.*?):\s*/i, '').strip
  end
end

if __FILE__ == $0
  WritingAssistant.new
end
