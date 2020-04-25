class Query < ApplicationRecord
  def get_data
    def get_info(sym, auth_token)
      date = Date.parse("Friday")
      Date.today >= date ? date = (date + 7.days).strftime("%Y-%m-%d") : date = date.strftime("%Y-%m-%d")
      request_url = "https://api.tdameritrade.com/v1/marketdata/chains?apikey=#{ENV['TD_CONSUMER_KEY']}&symbol=#{sym}&contractType=CALL&strikeCount=12&includeQuotes=TRUE&strategy=SINGLE&range=SBK&toDate=#{date}&fromDate=#{date}&optionType=S"

      response = Curl::Easy.http_get(request_url) do |curl|
        curl.headers["Authorization"] = "Bearer #{auth_token}"
      end

      return response
    end

    def check_auth(auth)
      # refresh auth_token if it's set to expire within 5 min
      if (auth.auth_token_exp - DateTime.now) < 1.minutes
        auth.td_refresh
      end

      return auth
    end

    auth = Auth.first
    
    syms = self.symbols.split(",")

    output = {}

    syms.each do |sym|
      puts "getting data for #{sym}..."
      output[sym] = {}
      # make sure auth_token isn't about to expire
      auth = check_auth(auth)
      response = get_info(sym, auth.auth_token)

      data = JSON.parse(response.body)

      # set market price for comparison
      mkt = data['underlyingPrice']
      output[sym]['mkt'] = mkt

      # remove any unnecessary data
      co = data['callExpDateMap'].first[1].filter { |k,v| k.to_f <= mkt }

      strikes = co.keys.sort

      five_bid = co[strikes[-5]][0]['bid']
      five_ask = co[strikes[-5]][0]['ask']
      five_mid = (five_bid + five_ask) / 2.0
      four_bid = co[strikes[-4]][0]['bid']
      four_ask = co[strikes[-4]][0]['ask']
      four_mid = (four_bid + four_ask) / 2.0
      three_bid = co[strikes[-3]][0]['bid']
      three_ask = co[strikes[-3]][0]['ask']
      three_mid = (three_bid + three_ask) / 2.0
      two_bid = co[strikes[-2]][0]['bid']
      two_ask = co[strikes[-2]][0]['ask']
      two_mid = (two_bid + two_ask) / 2.0

      output[sym]['five-three'] = {'strikes' => "#{strikes[-5]} - #{strikes[-3]}", 'lower_mid' => five_mid, 'upper_mid' => three_mid, 'diff_pct' => (five_mid - three_mid)/(strikes[-3].to_f - strikes[-5].to_f) }
      output[sym]['four-three'] = {'strikes' => "#{strikes[-4]} - #{strikes[-3]}", 'lower_mid' => four_mid, 'upper_mid' => three_mid, 'diff_pct' => (four_mid - three_mid)/(strikes[-3].to_f - strikes[-4].to_f) }
      output[sym]['three-two'] = {'strikes' => "#{strikes[-3]} - #{strikes[-2]}", 'lower_mid' => three_mid, 'upper_mid' => two_mid, 'diff_pct' => (three_mid - two_mid)/(strikes[-2].to_f - strikes[-3].to_f) }
    end

    return output
  end
end