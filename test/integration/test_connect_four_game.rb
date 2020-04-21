require_relative '../test_helper'
require_relative "../../app/models/connect_four"
require_relative "../../app/models/user"

class ConnectFourGameTest < Minitest::Test
    def setup
        @p1 = User.find(1)
        @p2 = User.find(2)

        @c4 = ConnectFour.new(
            player1_id: @p1.id,
            player2_id: @p2.id,
            tweet_id: '6969'
        )

        @log = Logger.new(STDOUT)
    end

    def test_should_start_game
        assert_equal '0' * ConnectFour::ROWS * ConnectFour::COLS, @c4.board
    end

    def test_users_can_play
        player1 = @c4.get_user_player(@p1)
        refute_nil player1

        win = @c4.play(player1, 1)
        assert_nil win

        player2 = @c4.get_user_player(@p2)
        refute_nil player2

        @c4.play(player2, 1)
        assert_nil win
    end

    def test_should_get_game_by_user
        @c4.save

        game = ConnectFour.find_by(player1: @p1, player2: @p2)
        assert_equal @c4, game

        @c4.destroy
    end

    def test_users_can_start_and_finish_game
        p1_username = 'adam'
        p2_username = 'barry'

        # Start the game with 2 new users
        msg = Parser.parse("I want to play c4 with @#{p2_username}", p1_username, '1', nil, @log, nil)
        expected =
                "1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n\n" +
                "Player 1: @#{p1_username}\n" +
                "Player 2: @#{p2_username}\n\n" +
                "Player 1's turn! Reply to this tweet with the drop keyword to play (e.g. 'drop 3' to drop a token on column 3)"

        assert_equal expected, msg

        # Player 1 plays
        msg = Parser.parse("Hmm... drop 2", p1_username, '2', 'test_id', @log, nil)
        expected =
                "1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️🍩⚪️⚪️⚪️⚪️⚪️\n\n" +
                "Turn: @#{p2_username}"


        assert_equal expected, msg

        # Player 2 plays
        msg = Parser.parse("Alrighty, then! Drop 3!", p2_username, '3', 'test_id', @log, nil)
        expected =
                "1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️🍩🍪⚪️⚪️⚪️⚪️\n\n" +
                "Turn: @#{p1_username}"

        assert_equal expected, msg

        # Players drop discs until player 2 wins
        Parser.parse("Drop 2", p1_username, '4', 'test_id', @log, nil)
        Parser.parse("Drop 3", p2_username, '5', 'test_id', @log, nil)
        Parser.parse("Drop 2", p1_username, '6', 'test_id', @log, nil)
        Parser.parse("Drop 3", p2_username, '7', 'test_id', @log, nil)
        Parser.parse("Drop 1", p1_username, '8', 'test_id', @log, nil)
        msg = Parser.parse("Drop 3", p2_username, '8', 'test_id', @log, nil)

        expected =
                "1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️🍪⚪️⚪️⚪️⚪️\n" +
                "⚪️🍩🍪⚪️⚪️⚪️⚪️\n" +
                "⚪️🍩🍪⚪️⚪️⚪️⚪️\n" +
                "🍩🍩🍪⚪️⚪️⚪️⚪️\n\n" +
                "@#{p2_username} Wins!\n\n Thank you for playing, @#{p2_username} and @#{p1_username}. Use the 'play' command again to start a new game"

        assert_equal expected, msg

        # Make sure game can't be played after it is finished
        msg = Parser.parse("Drop 3", p2_username, '9', 'test_id', @log, nil)
        expected = 'This game is already finished or expired'
        assert_equal expected, msg

        # Make sure players can start a new game
        msg = Parser.parse("Rematch time! Let's play c4 with @#{p1_username}", p2_username, '10', nil, @log, nil)
        expected =
            "1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
                "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n\n" +
                "Player 1: @#{p2_username}\n" + # Because P2 started the rematch, these are reversed
                "Player 2: @#{p1_username}\n\n" +
                "Player 1's turn! Reply to this tweet with the drop keyword to play (e.g. 'drop 3' to drop a token on column 3)"

        assert_equal expected, msg

        # Clean up
        ConnectFour.find_by(tweet_id:'test_id').destroy
    end
end
