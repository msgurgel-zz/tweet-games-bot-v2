require 'dotenv/load'

require 'pry'
require 'logger'

require 'twitter'

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

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


log.info("start listening for mentions...")
begin
    stream.filter( track: topics.join(",") ) do |object|
        log.info(object.text) if object.is_a? Twitter::Tweet
        twitter.update("@#{object.user.screen_name} Thanks for mentioning me ♥️🤖", in_reply_to_status: object)
    end
rescue Interrupt
    stream.close
    log.info("shutting down")
end
