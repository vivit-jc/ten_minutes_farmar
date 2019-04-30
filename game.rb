class Game
  attr_reader :status, :game_status, :mainview, :debug_arg, :messages, :farm, :date

  def initialize
  	@status = :title
  	@game_status = nil
  	@mainview = nil

    @date = {year: 1, season: 0, week: 0}

  	@messages = []
  	@debug_arg = 0

  	@farm = []
  	init_farm
  	@farm[0][0] = {kind: :land, str: "空"}

  end


  def init_farm
    p "init_farm"
    3.times do |y|
      tmp = []
      4.times do |x|
        prog = rand(2)+1
        tmp.push({kind: :wasteland, prog: prog, max: prog})
      end
      @farm.push tmp
    end
  end

  def start
  	@status = :game
  end

  def stats
  end

  def ranking
  end

  def click
  	@debug_arg += 1
  end

  def click_menu(pos)
  end

end