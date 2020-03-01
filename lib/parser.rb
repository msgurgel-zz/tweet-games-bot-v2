require_relative './dice'

module Parser
    def Parser.parse(tweet)
        words = tweet.downcase.split(' ')

        msg = self.check_for_roll_cmd(words)

        msg || self.default_response
    end

    def self.default_response
        "Thanks for mentioning me ♥️🤖"
    end

    def self.check_for_roll_cmd(words)
        roll_index = words.find_index('roll')
        if roll_index
            after_roll = words.slice(roll_index + 1, words.length)
            dice = after_roll.select { |w| w.match(/d\d+/) }

            if !dice.empty?
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
end
