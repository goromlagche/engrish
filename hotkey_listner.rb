#!/usr/bin/env ruby

# Hotkey Listener for Writing Assistant
# Listens for Ctrl+Ctrl (double Ctrl tap) and triggers text processing

class HotkeyListener
  def initialize
    @trigger_file = "/tmp/writing_assistant_trigger"
    @last_ctrl_time = 0
    @ctrl_double_tap_window = 0.5  # seconds
    @running = false

    puts "🎯 Hotkey listener started - Listening for Ctrl+Ctrl..."
  end

  def start
    @running = true

    # Clean up any existing trigger file
    File.delete(@trigger_file) if File.exist?(@trigger_file)

    begin
      if command_exists?('xinput')
        detect_with_xinput
      else
        puts "⚠️  xinput not available, using manual trigger mode"
        puts "💡 Create /tmp/manual_trigger file to test"
        monitor_manual_trigger
      end
    rescue => e
      puts "❌ Hotkey detection error: #{e.message}"
      puts "💡 Falling back to manual trigger mode"
      monitor_manual_trigger
    end
  end

  def stop
    @running = false
  end

  private

  def detect_with_xinput
    puts "🎯 Using xinput for hotkey detection"

    IO.popen('xinput test-xi2 --root 2>/dev/null') do |pipe|
      pipe.each_line do |line|
        break unless @running

        # Look for Ctrl key press events (Detail 37 = left ctrl, 105 = right ctrl)
        if line.match(/KeyPress.*Detail:\s+(37|105)/)
          handle_ctrl_press
        end
      end
    end
  rescue => e
    puts "❌ xinput detection failed: #{e.message}"
    monitor_manual_trigger
  end

  def monitor_manual_trigger
    puts "🔧 Manual trigger mode active"
    puts "💡 Create /tmp/manual_trigger file to test"

    while @running
      if File.exist?('/tmp/manual_trigger')
        puts "⚡ Manual trigger detected!"
        File.delete('/tmp/manual_trigger')
        create_trigger
      end
      sleep 0.1
    end
  end

  def handle_ctrl_press
    current_time = Time.now.to_f
    time_diff = current_time - @last_ctrl_time

    if time_diff < @ctrl_double_tap_window && time_diff > 0.05
      puts "⚡ Ctrl+Ctrl detected! Triggering writing assistant..."

      # Copy selected text to clipboard first
      if command_exists?('xdotool')
        system('xdotool key ctrl+c 2>/dev/null')
        sleep 0.2  # Give time for copy to complete
      end

      create_trigger

      # Reset timer to prevent triple-taps
      @last_ctrl_time = 0
    else
      @last_ctrl_time = current_time
    end
  end

  def create_trigger
    # Create trigger file to signal writing assistant
    File.write(@trigger_file, Time.now.to_s)
  end

  def command_exists?(command)
    system("which #{command} > /dev/null 2>&1")
  end
end

# Run the hotkey listener
if __FILE__ == $0
  begin
    listener = HotkeyListener.new
    listener.start
  rescue Interrupt
    puts "\n👋 Hotkey listener stopped!"
    exit(0)
  end
end
