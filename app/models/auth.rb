class Auth < ApplicationRecord
  def get_td_auth_token
    def ff_driver_options
      options = Selenium::WebDriver::Firefox::Options.new(binary: ENV['FIREFOX_BIN'])
      arguments = %w[--headless]
      arguments.each do |argument|
        options.add_argument(argument)
      end
      options
    end

    def ff_setup_driver
      service = Selenium::WebDriver::Service.firefox(path: Selenium::WebDriver::Firefox::Service.driver_path)
      driver = Selenium::WebDriver.for :firefox, service: service, options: ff_driver_options
      driver.manage.timeouts.implicit_wait = 5
      driver.manage.timeouts.page_load = 5
      driver.manage.timeouts.script_timeout = 5
      driver
    end

    def ch_driver_options
      options = Selenium::WebDriver::Chrome::Options.new(binary: ENV['GOOGLE_CHROME_BIN'])
      arguments = %w[--headless --disable-gpu --no-sandbox --remote-debugging-port=9222]
      arguments.each do |argument|
        options.add_argument(argument)
      end
      options
    end

    def ch_setup_driver
      Selenium::WebDriver::Chrome.path = ENV['GOOGLE_CHROME_BIN']
      service = Selenium::WebDriver::Service.chrome(path: Selenium::WebDriver::Chrome::Service.driver_path)
      driver = Selenium::WebDriver.for :chrome, service: service, options: ch_driver_options
      driver.manage.timeouts.implicit_wait = 5
      driver.manage.timeouts.page_load = 5
      driver.manage.timeouts.script_timeout = 5
      driver
    end

    puts "Authorizing via OAuth..."
    Rails.env == "production" ? driver = ch_setup_driver : ff_setup_driver
    driver.get("https://auth.tdameritrade.com/auth?response_type=code&redirect_uri=http://spread-finder.herokuapp.com&client_id=#{ENV['TD_CONSUMER_KEY']}%40AMER.OAUTHAP")
    usr = driver.find_element(id: "username")
    usr.send_keys ENV['TD_USR']
    pwd = driver.find_element(id: "password")
    pwd.send_keys ENV['TD_PWD']
    submit = driver.find_element(id: "accept")
    submit.submit
    sleep 1
    # sequence to use secret questions
    puts "Requesting and answering secret question..."
    alt = driver.find_element(xpath: "//summary[@class='row']")
    alt.click
    sleep 1
    sq = driver.find_element(xpath: "//input[@name='init_secretquestion']")
    sq.click
    sleep 1
    ans = driver.find_element(id: "secretquestion")
    if driver.page_source["high school"] # high school city
      ans.send_keys ENV['SQ_HS']
    elsif driver.page_source["paternal grandmother"] # paternal grandmother's first name
      ans.send_keys ENV['SQ_PG']
    elsif driver.page_source["best man"] # first name of best man
      ans.send_keys ENV['SQ_BM']
    elsif driver.page_source["spouse"] # city met spouse
      ans.send_keys ENV['SQ_MS']
    else
      puts "ERROR:  Do not recognize security question... please try again"
      driver.close
      return false
    end

    # Submit secret questions
    cont = driver.find_element(id: "accept")
    cont.submit
    sleep 1

    # Accept credentials
    allow = driver.find_element(id: "accept")
    allow.submit
    sleep 1

    # Save credentials and close selenium
    code_url = driver.current_url
    driver.close

    # get and return code
    puts "Getting grant_code..."
    code_match = code_url.match(/code=(.*)\z/)
    if code_match
      # code = URI.decode(code[1])
      code = code_match[1]
    else
      puts "Con't wasn't properly extracted"
      return false
    end

    # use code to get auth_token and refresh_token
    puts "Using grant_code to get auth credentials..."
    response = Curl::Easy.http_post("https://api.tdameritrade.com/v1/oauth2/token", "grant_type=authorization_code&access_type=offline&code=#{code}&client_id=#{ENV['TD_CONSUMER_KEY']}%40AMER.OAUTHAP&redirect_uri=#{URI.encode('http://spread-finder.herokuapp.com')}") do |curl|
      curl.headers["Content-Type"] = "application/x-www-form-urlencoded"
    end

    json = JSON.parse(response.body)

    if json['access_token']
      puts "Success!  Saving credentials."
      self.update(auth_token: json['access_token'], refresh_token: json['refresh_token'], auth_token_exp: DateTime.now + (json['expires_in'].to_i).seconds, refresh_token_exp: DateTime.now + (json['refresh_token_expires_in'].to_i).seconds)
    else
      puts "Something went wrong.  JSON doesn't contain auth credentials.  Please audit code."
      return false
    end
  end

  def td_refresh
    puts "Using grant_code to refresh auth credentials..."
    response = Curl::Easy.http_post("https://api.tdameritrade.com/v1/oauth2/token", "grant_type=refresh_token&#{URI.encode_www_form([['refresh_token',self.refresh_token]])}&access_type=offline&code=&client_id=#{ENV['TD_CONSUMER_KEY']}%40AMER.OAUTHAP&redirect_uri=") do |curl|
      curl.headers["Content-Type"] = "application/x-www-form-urlencoded"
    end

    json = JSON.parse(response.body)

    if json['access_token']
      puts "Success!  Saving credentials."
      self.update(auth_token: json['access_token'], refresh_token: json['refresh_token'], auth_token_exp: DateTime.now + (json['expires_in'].to_i).seconds, refresh_token_exp: DateTime.now + (json['refresh_token_expires_in'].to_i).seconds)
    else
      puts "Something went wrong.  JSON doesn't contain auth credentials.  Please audit code."
      return false
    end
  end
end
