class Spread < ApplicationRecord
  include DataConcern

  def self.daily_pull
    # set sym array
    syms = Listing.first.symbols
    # set date needs
    today = DateTime.now.in_time_zone("Eastern Time (US & Canada)")
    year_week = today.strftime("%G-%V")
    case today.strftime("%A")
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
    # set auth
    auth = Auth.first
    auth = DataConcern.check_auth(auth)
    # get underlying data
    response = DataConcern.get_close(syms.gsub("\/", "."), auth.auth_token) # replace slashes with dots to make sure syms with slashes are parsed properly
    close_hash = JSON.parse(response.body)
    # save underlying data for each sym
    close_hash.keys.each do |sym|
      puts "Saving data for #{sym}..."
      spread = Spread.find_by(sym: sym.gsub(".", "/"), year_week: year_week)
      mkt = close_hash[sym]["closePrice"]

      if !spread
        begin
          # if this is a new object, get all of the information
          response = DataConcern.get_info(sym, auth.auth_token)
          data = JSON.parse(response.body)

          # skip if sym doesn't exist
          if data['status'] == "FAILED"
            next
          end

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

          five_three_val = five_mid - three_mid
          four_three_val = four_mid - three_mid
          three_two_val = three_mid - two_mid

          spread = Spread.create(sym: sym.gsub(".", "/"), year_week: year_week, "underlying_#{day}".to_sym => mkt, strike_5: strikes[-5], strike_4: strikes[-4], strike_3: strikes[-3], strike_2: strikes[-2], "five_three_val_#{day}".to_sym => five_three_val, "four_three_val_#{day}".to_sym => four_three_val, "three_two_val_#{day}".to_sym => three_two_val)
        rescue
          # if there is an error in the collection, just move on to the next
          next
        end
      else
        info = {}

        info['mkt'] = mkt
        # if this is an existing object, just update by strike prices to be sure that the range hasn't changed
        [spread.strike_5, spread.strike_4, spread.strike_3, spread.strike_2].each do |strike|
          response = DataConcern.get_info(sym, auth.auth_token, strike)
          data = JSON.parse(response.body)

          # skip if sym doesn't exist
          if data['status'] == "FAILED"
            next
          end

          data_set = data['callExpDateMap'].first[1].first[1][0]

          bid = data_set['bid']
          ask = data_set['ask']
          mid = (bid + ask) / 2.0

          info[strike] = mid
        end

        five_three_val = info[spread.strike_5] - info[spread.strike_3]
        four_three_val = info[spread.strike_4] - info[spread.strike_3]
        three_two_val = info[spread.strike_3] - info[spread.strike_2]

        spread.update("underlying_#{day}".to_sym => info['mkt'], "five_three_val_#{day}".to_sym => five_three_val, "four_three_val_#{day}".to_sym => four_three_val, "three_two_val_#{day}".to_sym => three_two_val)
      end
    end
  end
end
