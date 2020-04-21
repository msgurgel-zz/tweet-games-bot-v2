require_relative '../test_helper'
require_relative '../../lib/parser'
require_relative '../../app/models/user'

class ParserTest < Minitest::Test
    def setup
        @player1 = User.find(1)
        @player2 = User.find(3)
        @log = Logger.new(STDOUT)
    end

    def test_should_parse_roll
        @parser_parse = Parser.parse('roll d6', 'foo', '1', nil, @log, nil)
        msg = @parser_parse
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse('roll d1', 'foo', '1', nil, @log, nil)
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse('roll d100', 'foo', '1', nil, @log, nil)
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse('@TweetGamesBot ROLL me a D20', 'foo', '1', nil, @log, nil)
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse("Let's see if I'm lucky: @TweetGamesBot, roll a d69", 'foo', '1', nil, @log, nil)
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse("@delart_sweet @TweetGamesBot it's roll d6, dude", 'foo', '1', nil, @log, nil)
        assert msg.match(/^Your d\d+ result was \d+$/)

        msg = Parser.parse("@TweetGamesBot roll me a d89, bot", 'foo', '1', nil, @log, nil)
        assert msg.match(/^Your d\d+ result was \d+$/)
    end

    def test_should_not_roll_pass_100
        msg = Parser.parse('roll d101', 'foo', '1', nil, @log, nil)
        assert_equal 'Dice number cannot be above 100', msg

        msg = Parser.parse('roll d200', 'foo', '1', nil, @log, nil)
        assert_equal 'Dice number cannot be above 100', msg

        msg = Parser.parse('roll d99999', 'foo', '1', nil, @log, nil)
        assert_equal 'Dice number cannot be above 100', msg
    end

    def test_should_not_roll_d0
        msg = Parser.parse('roll d0', 'foo', '1', nil, @log, nil)
        assert_equal 'Dice number cannot be below 1', msg
    end

    def test_should_not_parse_d_below_zero
        result = Parser.parse('roll d-1', 'foo', '1', nil, @log, nil)
        assert_equal "Thanks for mentioning me ♥️🤖", result

        result = Parser.parse('roll d-9999', 'foo', '1', nil, @log, nil)
        assert_equal "Thanks for mentioning me ♥️🤖", result
    end

    def test_should_drop_a_token_in_connect_four
        result = Parser.parse('drop 1', @player1.username, '2','fixture_id', @log, nil)
        expected =
        "1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣\n" +
        "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
        "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
        "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
        "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
        "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
        "🍩⚪️⚪️⚪️⚪️⚪️⚪️\n\n" +
        "Turn: @#{@player2.username}"

        assert_equal(expected, result)
    end

    def test_should_start_a_game_of_connect_four
        result = Parser.parse('play c4 with @gurgelino', @player1.username, '2', nil, @log, nil)
        expected =
                "1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n\n" +
                "Player 1: @#{@player1.username}\n" +
                "Player 2: @gurgelino\n\n" +
                "Player 1's turn! Reply to this tweet with the drop keyword to play (e.g. 'drop 3' to drop a token on column 3)"

        assert_equal(expected, result)

        # Clean up
        ConnectFour.find_by(tweet_id:'test_id').destroy
    end
end