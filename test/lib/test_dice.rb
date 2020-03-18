require_relative '../test_helper'
require_relative '../../lib/dice'

class DiceTest < Minitest::Test
    def test_should_roll_dice
        result = Dice.roll(4)
        assert result.between?(1,4)

        result = Dice.roll(6)
        assert result.between?(1,6)

        result = Dice.roll(8)
        assert result.between?(1,8)

        result = Dice.roll(10)
        assert result.between?(1,10)

        result = Dice.roll(12)
        assert result.between?(1,12)

        result = Dice.roll(20)
        assert result.between?(1,20)

        result = Dice.roll(100)
        assert result.between?(1,100)
    end

    def test_should_not_accept_dice_pass_100
        e = assert_raises ArgumentError  do
            Dice.roll(101)
        end
        assert_equal 'Dice number cannot be above 100', e.message

        e = assert_raises ArgumentError  do
            Dice.roll(200)
        end
        assert_equal 'Dice number cannot be above 100', e.message

        e = assert_raises ArgumentError  do
            Dice.roll(999999)
        end
        assert_equal 'Dice number cannot be above 100', e.message
    end

    def test_should_not_accept_dice_below_zero
        e = assert_raises ArgumentError  do
            Dice.roll(0)
        end
        assert_equal 'Dice number cannot be below 1', e.message

        e = assert_raises ArgumentError  do
            Dice.roll(-1)
        end
        assert_equal 'Dice number cannot be below 1', e.message

        e = assert_raises ArgumentError  do
            Dice.roll(-9999)
        end
        assert_equal 'Dice number cannot be below 1', e.message
    end
end