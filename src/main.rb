require 'dotenv/load'
require 'twitter'
require 'pry'

stream = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

twitter = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

# Stream tweets?
topics = ["@TweetGamesBot"]
stream.filter( track: topics.join(",") ) do |object|
    puts object.text if object.is_a? Twitter::Tweet
    twitter.update("@#{object.user.screen_name} Thanks for mentioning me ♥️🤖", in_reply_to_status: object)
end