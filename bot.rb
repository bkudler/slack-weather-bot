require 'dotenv/load'
require 'slack-ruby-bot'
require './weatherfetcher.rb'
require 'active_support/time'
require 'slack-ruby-client'



class Bot < SlackRubyBot::Bot

  api_key = ENV["weather_key"]
  weather_fetcher = DarksyWeatherFetcher.new({url:"https://api.darksky.net/forecast/"+api_key+"/"
  })


  command 'weather now' do |client, data, _match|
    #for some reason class methods were giving me trouble so I duplicated this code. This code could also probably be written as a case statement or, better yet, a hash that maps cities to lat long OR, even better yet, a class that goes to an external API that will convert cities to lat/long combos. However, time was limited so I went with this
    location = _match.to_s.split(" ")[3..-1].join(" ")
    if location.downcase === "los angeles"
      weather_fetcher.coordinates = '34.0522,118.2437'
    elsif location.downcase === "chicago"
      weather_fetcher.coordinates = '41.8781,87.6298'
    elsif location.downcase === "random"
      lat = -90.000 + Random.rand(90.000)
      long = -180.000 + Random.rand(180.000)
      weather_fetcher.coordinates = lat.to_s+","+long.to_s
    else
      weather_fetcher.coordinates = '42.3601,-71.0589'
    end


    report = weather_fetcher.weather("today")
    client.say(channel: data.channel, text: report)
  end

  command 'weather tomorrow' do |client, data, _match|
    #for some reason class methods were giving me trouble so I duplicated this code. This code could also probably be written as a case statement or, better yet, a hash that maps cities to lat long OR, even better yet, a class that goes to an external API that will convert cities to lat/long combos. However, time was limited so I went with this
    location = _match.to_s.split(" ")[3..-1].join(" ")
    if location.downcase === "los angeles"
      weather_fetcher.coordinates = '34.0522,118.2437'
    elsif location.downcase === "chicago"
      weather_fetcher.coordinates = '41.8781,87.6298'
    elsif location.downcase === "random"
      lat = -90.000 + Random.rand(90.000)
      long = -180.000 + Random.rand(180.000)
      weather_fetcher.coordinates = lat.to_s+","+long.to_s
    else
      weather_fetcher.coordinates = '42.3601,-71.0589'
    end


    time = (Time.now + 1.day).to_time.to_i
    report = weather_fetcher.weather(time)
    client.say(channel: data.channel, text: report)
  end


  command 'weather whenever' do |client, data, _match|
    #enter in a day, positive or negative, to see the weather on that day
    # e.g. 'weather whenever 50' shows the weather 50 days from now or 'weather whenever -30' shows the weather 30 days ago
    time = _match.to_s.split(" ")[-1..-1].join(" ")
    if !!(time =~ /\A[-+]?[0-9]+\z/) and time.to_i < 90
      time = (Time.now + time.to_i.day).to_time.to_i
      report = weather_fetcher.weather(time)
      client.say(channel: data.channel, text: report)
    else
      client.say(channel: data.channel, text: "sorry please make sure the last value is the number of days in the future or past you would like to see the weather for and is under 90 and greater than -90")
    end

  end




end

SlackRubyBot::Client.logger.level = Logger::WARN


class WeatherDifferentPoster

  attr_reader :weather_fetcher, :weather_today, :weather_yesterday




  def initialize(args)
    @weather_fetcher = args.fetch(:weather_fetcher, false) 
    Slack.configure do |config|
      config.token = ENV['slack_key']
    end
    @client =  Slack::Web::Client.new   
  end

  def weather_different?
   @weather_today = JSON.parse(@weather_fetcher.get_weather.body)["currently"]["temperature"].to_s
   tomorrow = (Time.now - 1.day).to_time.to_i
   @weather_yesterday = JSON.parse(@weather_fetcher.get_weather_time_machine(tomorrow).body)["currently"]["temperature"].to_s
    (@weather_today.to_f - @weather_yesterday.to_f).abs > 25
  end

  def talk_to_channel
    if weather_different?
      text = "the weather is going to be very different from yesterday. Yesterday it was " + @weather_yesterday + ". Today it is going to be " + @weather_today + " ."
      @client.chat_postMessage(channel: 'benk-interview-room', text: text, as_user: true)
    end
  end

end

weather_key = ENV["weather_key"]
weather_fetcher = DarksyWeatherFetcher.new({url:"https://api.darksky.net/forecast/"+weather_key+"/"
})

compare_weather = WeatherDifferentPoster.new({
  weather_fetcher: weather_fetcher
})


#the deployment server would have a cron job that ran this once a day. In real life this would be in a different file for the sake of that cron Job, I just put it here for ease.
compare_weather.talk_to_channel




Bot.run