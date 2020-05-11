class Listing < ApplicationRecord
  include DataConcern

  def get_data
    auth = Auth.first
    syms = self.symbols.split(",")
    output = {}

    syms.each do |sym|
      puts "getting data for #{sym}..."
      output[sym] = {}
      # make sure auth_token isn't about to expire
      auth = DataConcern.check_auth(auth)
      
      response = DataConcern.get_info(sym, auth.auth_token)
      data = JSON.parse(response.body)

      response2 = DataConcern.get_month_ohlc(sym, auth.auth_token)
      ohlc = JSON.parse(response2.body)

      begin
        # set month high and low
        output[sym]['high'] = ohlc['candles'].map { |c| c['high'] }.max
        output[sym]['low'] = ohlc['candles'].map { |c| c['low'] }.min
        # set market price for comparison
        mkt = data['underlyingPrice']
        output[sym]['mkt'] = mkt

        # remove any unnecessary data
        co = data['callExpDateMap'].first[1].filter { |k,v| k.to_f <= mkt }

        strikes = co.keys.sort_by { |k| k.to_i }

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
      rescue
        error_out = {
          'mkt' => 0, 
          'five-three' => { 'strikes' => "0 - 0", 'lower_mid' => 0, 'upper_mid' => 0, 'diff_pct' => 0 },
          'four-three' => { 'strikes' => "0 - 0" , 'lower_mid' => 0, 'upper_mid' => 0, 'diff_pct' => 0},
          'three-two' => { 'strikes' => "0 - 0", 'lower_mid' => 0, 'upper_mid' => 0, 'diff_pct' => 0 }
        }
        puts "Something went wrong with the data for #{sym}"
        output[sym] = error_out
      end        
    end

    return output
  end

  def get_data_individ(sym)
    auth = Auth.first
    output = {}

    puts "getting data for #{sym}..."
    # make sure auth_token isn't about to expire
    auth = DataConcern.check_auth(auth)
    
    response = DataConcern.get_info(sym, auth.auth_token)
    data = JSON.parse(response.body)

    response2 = DataConcern.get_month_ohlc(sym, auth.auth_token)
    ohlc = JSON.parse(response2.body)

    begin
      # set month high and low
      output['high'] = ohlc['candles'].map { |c| c['high'] }.max
      output['low'] = ohlc['candles'].map { |c| c['low'] }.min
      # set market price for comparison
      mkt = data['underlyingPrice']
      output['mkt'] = mkt

      # remove any unnecessary data
      co = data['callExpDateMap'].first[1].filter { |k,v| k.to_f <= mkt }

      strikes = co.keys.sort_by { |k| k.to_i }

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

      output['five-three'] = {'strikes' => "#{strikes[-5]} - #{strikes[-3]}", 'lower_mid' => five_mid, 'upper_mid' => three_mid, 'diff_pct' => (five_mid - three_mid)/(strikes[-3].to_f - strikes[-5].to_f) }
      output['four-three'] = {'strikes' => "#{strikes[-4]} - #{strikes[-3]}", 'lower_mid' => four_mid, 'upper_mid' => three_mid, 'diff_pct' => (four_mid - three_mid)/(strikes[-3].to_f - strikes[-4].to_f) }
      output['three-two'] = {'strikes' => "#{strikes[-3]} - #{strikes[-2]}", 'lower_mid' => three_mid, 'upper_mid' => two_mid, 'diff_pct' => (three_mid - two_mid)/(strikes[-2].to_f - strikes[-3].to_f) }
    rescue
      error_out = {
        'mkt' => 0, 
        'five-three' => { 'strikes' => "0 - 0", 'lower_mid' => 0, 'upper_mid' => 0, 'diff_pct' => 0 },
        'four-three' => { 'strikes' => "0 - 0" , 'lower_mid' => 0, 'upper_mid' => 0, 'diff_pct' => 0},
        'three-two' => { 'strikes' => "0 - 0", 'lower_mid' => 0, 'upper_mid' => 0, 'diff_pct' => 0 }
      }
      puts "Something went wrong with the data for #{sym}"
      output = error_out
    end        

    return output
  end
end