require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

require_relative "../../app/models/connect_four"

class ConnectFourTest < Minitest::Test
    def setup
        @test_board =
        '0000000' +
        '0001000' +
        '0011001' +
        '0022002' +
        '1212021' +
        '1221112'

        @connect4 = ConnectFour.new(@test_board)
    end

    def test_board_is_init_properly
        assert_equal @test_board, @connect4.board_string
        assert @connect4.player1_turn?
    end

    def test_play_should_drop_disc_into_board
        @connect4.play(1, 1)

        expected_board =
        '0000000' +
        '0001000' +
        '0011001' +
        '1022002' + # Added 1 to the beginning of this row
        '1212021' +
        '1221112'

        assert_equal expected_board, @connect4.board_string
        assert @connect4.player2_turn?
    end

    def test_should_not_drop_disc_in_full_col
        full_col =
        '1000000' +
        '1001000' +
        '2011001' +
        '1022002' +
        '1212021' +
        '1221112'

        connect4_full_col = ConnectFour.new(full_col)

        assert_raises Exceptions::FullColumnError do
            connect4_full_col.play(1,1)
        end
    end

    def test_play_should_raise_when_user_plays_out_of_turn
        assert_raises Exceptions::PlayOutOfTurnError do
            @connect4.play(2, 1)
        end
    end

    def test_is_player_turn_raises_if_invalid_player_num_is_passed
        assert_raises ArgumentError do
            @connect4.is_player_turn?(3)
        end
    end

    def test_should_output_proper_emoji_board
        expected_emoji_board =
        "1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣\n" +
        "⚪️⚪️⚪️⚪️⚪️⚪️⚪️\n" +
        "⚪️⚪️⚪️🍩⚪️⚪️⚪️\n" +
        "⚪️⚪️🍩🍩⚪️⚪️🍩\n" +
        "⚪️⚪️🍪🍪⚪️⚪️🍪\n" +
        "🍩🍪🍩🍪⚪️🍪🍩\n" +
        "🍩🍪🍪🍩🍩🍩🍪"

        assert_equal expected_emoji_board, @connect4.emoji_board
    end

    def test_should_win_if_four_in_a_row_vertical
        win_board =
        '0000000' +
        '0000000' +
        '0000000' +
        '1000200' +
        '1000200' +
        '1000200'

        c4 = ConnectFour.new(win_board)
        winner = c4.play(1,1)
        assert_equal 1, winner
    end

    def test_should_win_if_four_in_a_row_horizontal
        win_board =
        '0000000' +
        '0000000' +
        '0000000' +
        '0000020' +
        '0000020' +
        '1110020'

        c4 = ConnectFour.new(win_board)
        winner = c4.play(1,4)
        assert_equal 1, winner
    end

    def test_should_win_if_four_in_a_row_diagonal_right
        win_board =
        '0000000' +
        '0000000' +
        '0000000' +
        '0011000' +
        '0122000' +
        '1121000'

        c4 = ConnectFour.new(win_board)
        winner = c4.play(1,4)
        assert_equal 1, winner
    end

    def test_should_win_if_four_in_a_row_diagonal_left
        win_board =
        '0000000' +
        '0000000' +
        '0000000' +
        '0011000' +
        '0122100' +
        '1121210'

        c4 = ConnectFour.new(win_board)
        winner = c4.play(1,3)
        assert_equal 1, winner
    end
end