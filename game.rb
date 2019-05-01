class Game
  attr_reader :status, :game_status, :mainview, :mainmenu, :debug_arg, :messages, :farm, :date, :money, :reputation

  def initialize
  	@status = :title
  	@game_status = nil
  	@mainview = nil
  	@mainmenu = :command

    @date = {year: 1, season: 0, week: 0}
    @money = 0
    @reputation = 0

    @part = 0

  	@messages = Array.new(3)
  	@debug_arg = 0

  	@farm = Array.new(12)
  	init_farm

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
  	case @mainmenu
  	when :command
  	  select_command(pos)
  	when :seeds
  	  select_seeds(pos)
  	end
  end

  def select_command(pos)
  	case MAIN_MENU_TEXT.to_a[pos][0]
  	when :part
  	  @debug_arg += 10
  	end
  end

  def select_seeds(pos)
  end

  def click_farm(pos)
    #Sound[:shovel].play
    farm = @farm[pos]
    if farm[:kind] == :wasteland
      farm[:prog] -= 1
      gain_time
      @messages[0] = "畑を開墾した"
      if farm[:prog] == 0
        @farm[pos].merge!({kind: :land, str: "空"})
      end
    end
  end

  def gain_time
  	@date[:week] += 1
  	if @date[:week] == 4
  	  @date[:week] = 0
  	  @date[:season] += 1
  	end
  	if @date[:season] == 4
  	  @date[:season] = 0
  	  @date[:year] += 1
  	end
  end

  def init_farm
    @farm[0] = {kind: :land, str: "空"}
    11.times do |i|
      prog = rand(2)+1
      @farm[i+1] = {kind: :wasteland, prog: prog, max: prog}
    end
  end

end