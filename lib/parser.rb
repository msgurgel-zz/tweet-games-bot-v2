require_relative './dice'

# TODO: A lib file should not be requiring models. Rethink this
require_relative '../app/models/connect_four'
require_relative '../app/models/user'

module Parser
    def Parser.parse(tweet_text, author, tweet_id, in_reply_to_id, log, twitter)
        words = tweet_text.downcase.split(' ')

        msg = self.check_roll_cmd(words)

        msg = self.check_drop_cmd(author, words, tweet_id, in_reply_to_id, twitter, log) unless msg

        msg = self.check_play_cmd(author, tweet_id, words, log, twitter) unless msg

        msg || self.default_response
    end

    def self.default_response
        "Thanks for mentioning me ♥️🤖"
    end

    def self.check_roll_cmd(words)
        roll_index = words.find_index('roll')
        if roll_index
            after_roll = words.slice(roll_index + 1, words.length)

            if after_roll.empty?
                return 'No dice size given! Specify a dice size by entering dX after the word "roll" e.g roll a d20'
            end

            dice = after_roll.select { |w| w.match(/d\d+/) }

            unless dice.empty?
                # Extract number of dice
                dice = dice.first
                dice = dice.delete_prefix('d').to_i

                # Call the dice roll method & format tweet
                begin
                    result = Dice.roll(dice)
                    "Your d#{dice} result was #{result}"
                rescue ArgumentError => e
                    e.message
                end
            end
        end
    end

    def self.check_drop_cmd(username, words, tweet_id, in_reply_to_id, twitter, log)
        # drop - drops connect4 token on a column
        param_words = get_words_after_keyword(words, 'drop')
        unless param_words.nil? # Was 'drop' found?
            # drop was in the tweet. Is there a game of Connect4 going on?
            player = User.find_by(username: username.downcase)
            if player.nil?
                log.error "Player not found. username=#{username}"
                return "You're not a playing a Connect4 game! Tweet at me with `help connect4` for instructions on how to play."
            end

            # Get column to drop disc in
            col = param_words[0].to_i
            unless col >= 1 && col <= 7
                log.error "Invalid column given. col=#{col} | param_words=#{param_words}"
                return "Invalid column to drop disc. Please enter a number between 1 and 7 after the 'drop' keyword."
            end

            # TODO: Refactor this so it doesn't do two calls to the db
            c4 = ConnectFour.find_by(player1_id: player.id)
            player_num = 1

            if c4.nil?
                c4 = ConnectFour.find_by(player2_id: player.id)
                player_num = 2
            end

            if c4.nil? # Couldn't find a game
                log.error "C4 game not found. player_id=#{player.id}"
                return "You're not a playing a Connect4 game! Tweet at me with `help connect4` for instructions on how to play."
            end

            if c4.tweet_id != in_reply_to_id
                log.error "Replying to wrong tweet. expected_tweet_id=#{c4.tweet_id} | actual_tweet_id=#{in_reply_to_id}"
                return "Replying to wrong tweet. Please reply to the tweet that started the Connect4 game you're like to play instead."
            end

            # Convert the board string into an array so the game can be played
            c4.prepare_board

            # Drop the disc!
            begin
                winner = c4.play(player_num, col)
            rescue PlayOutOfTurnError
                log.error "Play out of turn. player_num=#{player_num} | player1_turn=#{c4.player1_turn?} | username=#{username}"
                return "It's not your turn yet!"
            rescue GameIsDoneError
                log.error "Tried to play finished game. game_status=#{c4.status} | username=#{username}"
                return "This game is already finished or expired"
            end

            players = []
            if player_num == 1
                next_turn_player = User.find(c4.player2_id)

                players.push(player.username)
                players.push(next_turn_player.username)
            else
                next_turn_player = User.find(c4.player1_id)

                players.push(player.username)
                players.push(next_turn_player.username)
            end

            msg = c4.emoji_board + "\n\n"

            if winner.nil?
                msg += "Turn: @#{next_turn_player.username}"
            else
                msg += "@#{players[0]} Wins!\n\n Thank you for playing, @#{players[0]} and @#{players[1]}. Use the 'play' command again to start a new game"
                c4.status = 'complete'
            end

            # Reply with the new board
            if twitter.nil?
                # Twitter object was nil. This will only happen when testing
                c4.save
                return msg
            end

            new_game_tweet = twitter.update("@#{username} #{msg} \n\nTime: #{Time.now.strftime("%H:%M:%S")}", in_reply_to_status_id: tweet_id)
            c4.tweet_id = new_game_tweet.id
            c4.save

            return 'noop'
        end
    end

    def self.check_play_cmd(username, tweet_id, words, log, twitter)
        # play - starts a new game
        param_words = get_words_after_keyword(words, 'play')
        unless param_words.nil? # was 'play' found?
            # TODO: Happy path first, add to this later

            unless param_words[0] == 'c4' || param_words == 'ConnectFour'
                log.error("Invalid params for 'play': #{words}")
                return "Invalid game name. Supported games: c4 (ConnectFour)"
            end

            unless param_words[1] == 'with' && param_words[2].start_with?('@')
                log.error("Invalid params for 'play': #{words}")
                return "Specify who you're playing with using 'with @username'"
            end

            # Start the connect 4 game
            # Find the players. If not found, create them
            player1 = User.find_by(username: username.downcase)
            if player1.nil?
                player1 = User.new(username: username.downcase)
                unless player1.save
                    log.error("Failed to save new user (player1) to db. username = #{username}")
                    return 'Something went wrong. Try again later'
                end
            end

            p2_username = param_words[2].delete_prefix('@').downcase
            player2 = User.find_by(username: p2_username)
            if player2.nil?
                player2 = User.new(username: p2_username)
                unless player2.save
                    log.error("Failed to save new user (player2) to db. username = #{p2_username}")
                    return 'Something went wrong. Try again later'
                end
            end


            # Make sure that these players don't already have a game going on
            # If so, delete that
            existing_game = ConnectFour.find_by(
                player1_id: player1.id,
                player2_id: player2.id
            ) || ConnectFour.find_by(
                player1_id: player2.id,
                player2_id: player1.id
            )

            unless existing_game.nil?
                # This now overwrites any existing games
                existing_game.destroy
                # return "Cannot start a new game. There's already a game going on between these two players!"
            end


            c4 = ConnectFour.new(
                player1_id: player1.id,
                player2_id: player2.id
            )

            # Reply to the tweet with empty board
            msg = c4.emoji_board + "\n\n" +
                    "Player 1: @#{player1.username}\n"+
                    "Player 2: @#{player2.username}\n\n"+
                    "Player 1's turn! Reply to this tweet with the drop keyword to play (e.g. 'drop 3' to drop a token on column 3)"

            if twitter.nil?
                # Twitter obj was passed as nil. This will only happen when testing
                c4.tweet_id = 'test_id'
                c4.save
                return msg
            end

            game_tweet = twitter.update("@#{username} #{msg} \n\nTime: #{Time.now.strftime("%H:%M:%S")}", in_reply_to_status_id: tweet_id)
            c4.tweet_id = game_tweet.id

            unless c4.save
                log.error("Failed to save new c4 to db. tweet_id=#{tweet_id} | player1_id=#{player1.id} | player2_id=#{player2.id}")
                return 'Something went wrong. Try again later'
            end

            return 'noop'
        end
    end

    def self.get_words_after_keyword(words, keyword)
        keyword_index = words.find_index(keyword)
        if keyword_index
            words.slice(keyword_index + 1, words.length)
        end
    end
end
