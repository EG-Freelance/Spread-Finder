desc "Update tracked stats"
task :daily_pull => :environment do
  # only pull Mon-Fri
  if Date.today.strfime("%u").to_i <= 5
    puts "Pulling daily stats"
    Spread.daily_pull
  end
end