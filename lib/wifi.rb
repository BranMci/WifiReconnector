class WiFiConnectionStatus
  def initialize
    @online    = true
    @count     = 0
    @interface = detect_interface
  end

  def reconnect
    `/usr/sbin/networksetup -setairportpower #{@interface} off`
    sleep(2)      
    `/usr/sbin/networksetup -setairportpower #{@interface} on`
  end

  def disconnection_count
    @online ? "\nDisconnection count: #{@count}" : ''
  end

  def check_connection
    puts "\nChecking connection on #{@interface}."
    result = %x(ping -W2 -c3 google.com 2>&1)
    if result["100.0% packet loss"] || result["Unknown"]
      @count += 1 if @online
      puts '  The internet is gone again' if @online
      reconnect
      @online = false
    else
      puts '  The internet is still active.' if @online
      puts '  The internet is back' unless @online
      @online = true
    end
  end

  def detect_interface
    active_interface = ""
    `ifconfig -lu`.split.each do |interface|
      status = `ifconfig #{interface}`
      unless status.scan(/status: active$/).empty?
        active_interface = interface
        break
      end
    end

    if active_interface.empty?
      puts "WiFi interface not found. Make sure your WiFi is turned on."
      exit
    else
      active_interface
    end
  end
end

wifi_checker = WiFiConnectionStatus.new

puts "WiFiConnectionStatus activated."

while true
  wifi_checker.check_connection
  sleep 5
end
