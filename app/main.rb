require 'dotenv/load'

require 'logger'
require 'twitter'
require_relative '../lib/parser'

# Setup connection to the database
require 'active_record'
db_config = YAML.load_file('db/config.yml')
ActiveRecord::Base.establish_connection(db_config[ENV['RAILS_ENV']])

# Turn off log buffering (for Heroku)
$stdout.sync = true
log = Logger.new(STDOUT)
log.level = Logger::DEBUG

# Connect to Twitter
# Streaming client for reading tweets
stream = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

# REST client for posting tweets
twitter = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

# Handle SIGTERM, which is how Heroku stops its apps
Signal.trap("TERM") {
    stream.close
    puts "received SIGTERM. shutting down"
    exit
}

# Handle SIGINT
Signal.trap("INT") {
    stream.close
    puts "received SIGINT. shutting down"
    exit
}

log.info("start listening for mentions...")
topics = ["@TweetGamesBot"]
begin
    stream.filter( track: topics.join(",") ) do |object|
        log.info("#{object.user.screen_name} said: #{object.text}") if object.is_a? Twitter::Tweet

        # TODO: Parser could become an object that is initialized before this call.
        # TODO: Make it so log and twitter are attributes of parser.
        # TODO: The name of this module is questionable. Rename to something that makes more sense.
        msg = Parser.parse(
            object.text,                        # Text of the tweet
            object.user.screen_name,            # Author of the tweet
            object.id.to_s,                     # Twitter's unique ID for the tweet
            object.in_reply_to_status_id.to_s,  # ID of the tweet the mention tweet is replying to
            log,                                # Log object
            twitter                             # Twitter object for posting tweets
        )
        unless msg == 'noop'
            twitter.update("@#{object.user.screen_name} #{msg} \n\nTime: #{Time.now.strftime("%H:%M:%S")}", in_reply_to_status: object)
            log.info("sending reply to #{object.user.screen_name}: #{msg}")
        end

    end
rescue JSON::ParserError => e
    if e.message == "767: unexpected token at 'Exceeded connection limit for user'"
        log.fatal("you just got rate limited! wait a couple minutes before trying again")
    else
        raise
    end
end
