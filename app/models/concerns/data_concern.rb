module DataConcern
  extend ActiveSupport::Concern

  def self.get_info(sym, auth_token, strike = "")
    date = Date.parse("Friday")
    Date.today >= date ? date = (date + 7.days).strftime("%Y-%m-%d") : date = date.strftime("%Y-%m-%d")
    request_url = "https://api.tdameritrade.com/v1/marketdata/chains?apikey=#{ENV['TD_CONSUMER_KEY']}&symbol=#{sym}&contractType=CALL&strikeCount=#{strike.blank? ? 12 : ""}&includeQuotes=TRUE&strategy=SINGLE&range=#{strike.blank? ? 'SBK' : ''}&toDate=#{date}&fromDate=#{date}&optionType=S&strike=#{strike}"

    response = Curl::Easy.http_get(request_url) do |curl|
      curl.headers["Authorization"] = "Bearer #{auth_token}"
    end

    return response
  end

  def self.check_auth(auth)
    # refresh auth_token if it's set to expire within 5 min
    if (auth.auth_token_exp - DateTime.now) < 1.minutes
      auth.td_refresh
    end

    return auth
  end
end