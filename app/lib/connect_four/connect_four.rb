require_relative 'exceptions'

class ConnectFour
    # Constants
    ROWS = 6
    COLS = 7

    # Emojis
    EMPTY_SLOT_EMOJI = '⚪️'
    PLAYER1_EMOJI    = '🍩'
    PLAYER2_EMOJI    = '🍪'
    COLUMN_EMOJIS    = ['1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣']

    attr_reader :moves

    def initialize(boardStr = nil, player1_turn = true)
        @board = []
        @moves = 0

        if !boardStr.nil?
            slots = boardStr.split('')

            i = 0
            while i < slots.length
                row = slots[i..(i + COLS - 1)]
                @board.push(row)
                i += COLS
            end

            @moves = (ROWS * COLS) - slots.count('0')
        else
            @board = Array.new(ROWS){Array.new(COLS, 0)}
        end

        # Initialize turn
        @player1_turn = player1_turn

    end

    # Format the board as a string, for easy db storage
    def board_string
        str = ""

        @board.each do |row|
            row.each do |slot|
                str += slot
            end
        end

        str
    end

    # Format the board as emoji board, to be displayed on Twitter
    def emoji_board
        emoji_board = ""

        # Add column numbers to the top
        COLUMN_EMOJIS.each {|emoji| emoji_board += emoji}
        emoji_board += "\n"

        # Fill the board!
        @board.each do |row|
            row.each do |slot|
                if slot == '0'
                    emoji_board += EMPTY_SLOT_EMOJI
                elsif slot == '1'
                    emoji_board += PLAYER1_EMOJI
                elsif slot == '2'
                    emoji_board += PLAYER2_EMOJI
                end
            end
            emoji_board += "\n"
        end

        emoji_board.strip
    end

    def player1_turn?
        @player1_turn
    end

    def player2_turn?
        !@player1_turn
    end

    def is_player_turn?(player)
        case player
        when 1
            player1_turn?
        when 2
            player2_turn?
        else
           raise ArgumentError.new('invalid player number. only accepts 1 or 2')
        end
    end

    def play(player, column)
        if !is_player_turn?(player)
            raise PlayOutOfTurnError.new("it's not your turn!")
        end

        column -= 1 # To deal with zero-base index on array

        # Check if column is full
        if @board[0][column].to_i > 0
            raise FullColumnError.new("column #{column + 1} is full!")
        end

        # Play the move
        disc_row = ROWS - 1
        @board.reverse_each do |row| # Start from the bottom of the board
            if row[column] == "0"
                row[column] = player.to_s # Drop disc!
                break
            end
            disc_row -= 1
        end

        # Add to the total number of moves played in this board
        @moves += 1

        # Toggle turn
        @player1_turn = !@player1_turn

        # Check if someone won and return the result
        check_winner(disc_row, column) if @moves >= 7 # There cannot be winner before at least 7 moves where played in total
    end

    def check_winner(row, col)
        winner = check_win_below(row, col)
        winner = check_win_horizontal(row, col) if !winner
        winner = check_win_diagonal(row, col) if !winner

        if winner
            return @board[row][col].to_i
        end
    end

    private

    def check_win_below(row, col)
        player = @board[row][col]
        count = 1 # The initial position already counts as one

        for i in row + 1..ROWS - 1 # From 1st row below the given coordinates to bottom row
            break if @board[i][col] != player || count == 4
            count += 1
        end

        count == 4
    end

    def check_win_horizontal(row, col)
        player = @board[row][col]
        count = 1 # The initial position already counts as one

        for i in col + 1..COLS - 1 # From 1st column right of the given coordinates to rightmost column
            break if @board[row][i] != player || count == 4
            count += 1
        end

        return true if count == 4

        i = col - 1 # From the 1st column left of the given one...
        while i >= 0
            break if @board[row][i] != player || count == 4
            count += 1
            i -= 1
        end

        count == 4
    end

    def check_win_diagonal(row, col)
        player = @board[row][col]
        count = 1 # The initial position already counts as one

        # Check right diagonal...
        # Up and to the right
        i = 1 # Skip the initial position
        while row - i >= 0 && col + i < COLS
            break if @board[row + i][col + i] != player || count == 4
            count += 1
            i += 1
        end

        return true if count == 4

        # Down and to the left
        i = 1
        while row + i < ROWS && col - i >= 0
            break if @board[row + i][col - i] != player || count == 4
            count += 1
            i += 1
        end

        return true if count == 4

        # Did not connect four in right diagonal...
        # Check left diagonal...
        count = 1

        # Up and to the left
        i = 1 # Skip the initial position
        while row - i >= 0 && col - i >= 0
            break if @board[row - i][col - i] != player || count == 4
            count += 1
            i += 1
        end

        return true if count == 4

        # Down and to the right
        i = 1
        while row + i < ROWS && col + i < COLS
            break if @board[row + i][col + i] != player || count == 4
            count += 1
            i += 1
        end

        count == 4
    end
end