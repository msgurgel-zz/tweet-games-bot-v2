require 'dotenv/load'

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

log.info("start listening for mentions...")

topics = ["@TweetGamesBot"]
begin
    stream.filter( track: topics.join(",") ) do |object|
        log.info(object.text) if object.is_a? Twitter::Tweet
        timeNow = Time.now.strftime("%H:%M:%S")
        twitter.update("@#{object.user.screen_name} Thanks for mentioning me ♥️🤖 Time: #{timeNow}", in_reply_to_status: object)
    end
rescue Interrupt
    stream.close
    log.info("shutting down")
rescue JSON::ParserError => e
    if e.message == "767: unexpected token at 'Exceeded connection limit for user'"
        log.fatal("you just got rate limited! err = #{e}")
    else
        raise
    end
end
