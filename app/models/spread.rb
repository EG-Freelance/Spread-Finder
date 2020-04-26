class Spread < ApplicationRecord
  def self.daily_pull
    syms = Query.first.symbols.split(",")
    today = Date.today
    auth = Auth.first
    year_week = today.strftime("%G-%V")
    syms.each do |sym|
      puts "Saving data for #{sym}..."
      if today.strftime("%A") == "Monday"
        spread = Spread.create(sym: sym, year_week: year_week)
      end
      auth = DataConcern.check_auth(auth)
      response = DataConcern.get_info(sym, auth)
      data = JSON.parse(response.body)
    end
  end
end
