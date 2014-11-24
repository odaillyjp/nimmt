module Nimmt
  class Controller
    def initialize(players_number: 1, computers_number: 3)
      @players = []
      @cards = Card.all.shuffle
      @rows = Row.all

      players_number.times { @players << Player.new(name: "あなた") }
      computers_number.times { |idx| @players << ComputerPlayer.new(name: "コンピュータ#{idx + 1}") }

      # プレイヤーにカードを10枚配る
      @players.each { |player| player.set_hand_cards(@cards.pop(10)) }

      # 場にカードをセットする
      @rows.each { |row| row.place_card(@cards.pop) }
    end

    def start
      while @players.first.hand_cards.size > 0
        puts_game_info
        played_cards = []

        # プレイヤーは場に出すカードを決める
        @players.each do |player|
          number = player.select_playing_card
          played_cards << player.play_card(number)
        end

        puts_played_cards(played_cards)

        played_cards.sort.each do |played_card|
          # 場に出ているカードのうち、最も近い数字のカードを探す
          prev_card = @rows.map(&:cards).map(&:last).select { |card| card < played_card }.max

          if prev_card.nil?
            # 置ける列がない場合、引き取る列をプレイヤーに決めさせる
            row = @rows[played_card.owner.select_row]

            # プレイヤーはカードを引き取る
            played_card.owner.take_cards_from_row(row)
          else
            # 最も近い数字のカードが置かれている列を取得する
            row = @rows.find { |row| row.has_card?(prev_card) }

            # その列にカードが5枚以上置かれているならば、プレイヤーはカードを引き取る
            played_card.owner.take_cards_from_row(row) if row.cards.size >= 5
          end

          # 列の後ろにカードを置く
          row.place_card(played_card)
        end
      end

      puts_result
    end

    private

    def puts_game_info
      puts "\n==== Turn Start ===="

      # TODO: @players.firstがプレイヤーではない場合でも問題ないようにする
      puts "# #{@players.first.name}が持っているカード"
      puts @players.first.hand_cards_info

      puts '# 場に出されているカード'
      @rows.each.with_index(1) do |row, idx|
        puts "## #{idx}列目"
        puts row.cards_info
      end
    end

    def puts_result
      puts "\n=== Result ==="

      @players.each do |player|
        puts "# #{player.name}のスコア"
        puts player.token_cards_info
      end
    end

    def puts_played_cards(played_cards)
      puts "\n=== みんなが出したカード ==="

      played_cards.each do |played_card|
        puts "#{played_card.owner.name}: #{played_card.number}"
      end

      sleep 1
    end
  end

  class Player
    attr_reader   :hand_cards, :name ,:token_cards

    def initialize(name: '名無し')
      @hand_cards  = []
      @token_cards = []
      @name        = name
    end

    def set_hand_cards(cards)
      cards.each { |card| card.owner = self }
      @hand_cards.push(*cards)
      @hand_cards.sort!
    end

    def has_card?(number)
      @hand_cards.any? { |card| card.number == number }
    end

    def play_card(number)
      card = @hand_cards.find { |card| card.number == number }
      @hand_cards.delete(card)
      card
    end

    def take_cards_from_row(row)
      @token_cards.push(*row.cards)
      row.clear
      puts "\n----"
      puts "#{name}は#{row.idx}列目のカードを引き取った。"
      puts token_cards_info
      sleep 1
    end

    def select_playing_card
      puts "\n----"
      puts '出すカードの数字を入力してね！'
      print '> '
      number = gets.chomp.to_i
      unless has_card?(number)
        puts "「#{number}」というカードは持っていない！"
        number = select_playing_card
      end
      number
    end

    def select_row
      puts '----'
      puts '何列目に出すか、数字で入力してね！'
      print '> '
      number = gets.chomp.to_i
      unless (1..4).include?(number)
        puts '1 〜4までの数字を入力してください。'
        number = select_row
      end
      number - 1
    end

    def hand_cards_info
      @hand_cards.map(&:number).join(' ')
    end

    def token_cards_info
      point = @token_cards.inject(0) { |acc, card| acc + card.cow }
      "失点: #{point}"
    end
  end

  class ComputerPlayer < Player
    # ランダムでカードを出す
    def select_playing_card
      @hand_cards.shuffle.first.number
    end

    # ランダムで置く列を選択する
    def select_row
      (1..4).to_a.shuffle.first - 1
    end
  end

  class Row
    attr_reader :cards, :idx

    def self.all
      rows = []
      4.times { |idx| rows << Row.new(idx: idx + 1) }
      rows
    end

    def initialize(idx: 1)
      @cards = []
      @idx   = idx
    end

    def place_card(card)
      @cards.push(card)
    end

    def has_card?(card)
      @cards.any? { |c| c == card }
    end

    def clear
      @cards.clear
    end

    def cards_info
      @cards.map(&:number).join(' ')
    end
  end

  class Card
    attr_reader   :number, :cow
    attr_accessor :owner

    include Comparable

    def self.all
      (1..104).map { |number| Card.new(number) }
    end

    def initialize(number, cow = 1)
      @number = number
      @cow    = cow
      @owner  = nil
    end

    def <=>(other)
      number <=> other.number
    end
  end
end
