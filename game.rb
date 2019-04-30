class Game
  attr_reader :status, :game_status, :mainview, :debug_arg

  def initialize
  	@status = :title
  	@game_status = nil
  	@mainview = nil

  	@debug_arg = 0
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