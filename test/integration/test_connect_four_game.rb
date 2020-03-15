require_relative '../test_helper'
require_relative "../../app/models/connect_four"
require_relative "../../app/models/user"

class ConnectFourGameTest < Minitest::Test
    def setup
        @p1 = User.find(1)
        @p2 = User.find(2)

        @c4 = ConnectFour.create(
            player1_id: @p1.id,
            player2_id: @p2.id,
        )
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
        game = ConnectFour.find_by(player1: @p1, player2: @p2)
        assert_equal @c4, game
    end

    def teardown
        @c4.destroy
        super
    end
end
