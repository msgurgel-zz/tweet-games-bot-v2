module Dice
    def Dice.roll(num)
        if num <= 0
            raise ArgumentError.new('Dice number cannot be below 1')
        end

        if num > 100
            raise ArgumentError.new('Dice number cannot be above 100')
        end

        rand(1..num)
    end
end