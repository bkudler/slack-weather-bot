require 'httparty'
require 'json'


class DarksyWeatherFetcher
  include HTTParty
  base_uri 'https://api.darksky.net/forecast'
  attr_accessor :coordinates
  attr_reader :time

  def initialize(args)
    @url = args.fetch(:url, false)
    @coordinates = args.fetch(:coordinates, '42.3601,-71.0589') 
    @weather_key = ENV["weather_key"]

  end

  def get_weather
    uri = "/"+@weather_key+"/" + self.coordinates
    self.class.get(uri,{query: {exclude:'minutely,hourly,daily,alerts,flags'}})
  end

  def get_weather_time_machine(date)
    uri = "/"+@weather_key+"/" + self.coordinates+","+date.to_s
    self.class.get(uri,{query: {exclude:'minutely,hourly,daily,alerts,flags'}})
  end

  def weather(time)
    if time === "today"
      weather = JSON.parse(self.get_weather.body)["currently"]
      @time = "today"
    else
      weather = JSON.parse(self.get_weather_time_machine(time).body)["currently"]
      @time = Time.at(time).strftime("%m/%d/%Y")
    end
      weather_report(weather)
  end

  def weather_report(weather)
    weather = OpenStruct.new(weather)
    @time + " it is " + weather.summary.downcase + " the temperature is " + weather.temperature.to_s + ". Don't worry, it feels like " + weather.apparentTemperature.to_s + ". you maybe driving, so you should know the cloud cover is " + weather.cloudCover.to_s + " and the visibility is " + weather.visibility.to_s + ". I don't know what a visibility of " + weather.visibility.to_s + " means, but, hey, I'm just a bot, I do know what the ozone is though. Wanna guess? I'll give you a second -------------------------------------------------------------------------------------------------------------------------

    Times up it is " + weather.ozone.to_s + ", whatever that means..."
  end



end