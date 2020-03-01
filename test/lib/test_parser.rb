require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

require_relative '../../lib/parser'

class ParserTest < Minitest::Test
    def test_should_parse_roll
        msg = Parser.parse('roll d6')
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse('roll d1')
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse('roll d100')
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse('@TweetGamesBot ROLL me a D20')
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse("Let's see if I'm lucky: @TweetGamesBot, roll a d69")
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse("@delart_sweet @TweetGamesBot it's roll d6, dude")
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse("@TweetGamesBot roll me a d89, bot")
        assert msg.match(/^Your d\d+ result was \d+$/)
   end

    def test_should_not_roll_pass_100
        msg = Parser.parse('roll d101')
        assert_equal 'Dice number cannot be above 100', msg

        msg = Parser.parse('roll d200')
        assert_equal 'Dice number cannot be above 100', msg

        msg = Parser.parse('roll d99999')
        assert_equal 'Dice number cannot be above 100', msg
    end

    def test_should_not_roll_d0
        msg = Parser.parse('roll d0')
        assert_equal 'Dice number cannot be below 1', msg
    end

    def test_should_not_parse_d_below_zero
        result = Parser.parse('roll d-1')
        assert_equal "Thanks for mentioning me ♥️🤖", result

        result = Parser.parse('roll d-9999')
        assert_equal "Thanks for mentioning me ♥️🤖", result
    end
end