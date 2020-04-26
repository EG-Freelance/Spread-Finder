class Spread < ApplicationRecord
  include DataConcern

  def self.daily_pull
    syms = Listing.first.symbols.split(",")
    today = Date.today
    auth = Auth.first
    year_week = today.strftime("%G-%V")
    syms.each do |sym|
      puts "Saving data for #{sym}..."
      spread = Spread.find_by(sym: sym, year_week: year_week)
      case Date.today.strftime("%A")
      when "Monday"
        day = "m"
      when "Tuesday"
        day = "t"
      when "Wednesday"
        day = "w"
      when "Thursday"
        day = "th"
      when "Friday"
        day = "f"
      else
        day = "f"
      end

      auth = DataConcern.check_auth(auth)
      if !spread
        # if this is a new object, get all of the information
        response = DataConcern.get_info(sym, auth.auth_token)
        data = JSON.parse(response.body)

        mkt = data['underlyingPrice']

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

        five_three_val = five_mid - three_mid
        four_three_val = four_mid - three_mid
        three_two_val = three_mid - two_mid

        spread = Spread.create(sym: sym, year_week: year_week, "underlying_#{day}".to_sym => mkt, strike_5: strikes[-5], strike_4: strikes[-4], strikes_3: strikes[-3], strikes_2: strikes[-2], "five_three_val_#{day}".to_sym => five_three_val, "four_three_val_#{day}".to_sym => four_three_val, "three_two_val_#{day}".to_sym => three_two_val)
      else
        info = {}
        # if this is an existing object, just update by strike prices to be sure that the range hasn't changed
        [spread.strike_5, spread.strike_4, spread.strike_3, spread.strike_2].each do |strike|
          response = DataConcern.get_info(sym, auth.auth_token, strike)
          data = JSON.parse(response.body)

          data_set = data['callExpDateMap'].first[1].first[1][0]

          bid = data_set['bid']
          ask = data_set['ask']
          mid = (bid + ask) / 2.0

          if !info["underlying"]
            info["underlying"] = data['underlyingPrice']
          end

          info[strike] = mid
        end

        five_three_val = info[spread.strike_5] - info[spread.strike_3]
        four_three_val = info[spread.strike_4] - info[spread.strike_3]
        three_two_val = info[spread.strike_3] - info[spread.strike_2]

        spread.update("underlying_#{day}".to_sym => mkt, "five_three_val_#{day}".to_sym => five_three_val, "four_three_val_#{day}".to_sym => four_three_val, "three_two_val_#{day}".to_sym => three_two_val)
      end
    end
  end
end
