class Game
  attr_reader :status, :game_status, :mainview, :mainmenu, :debug_arg, :messages, :farm, :date, :money, :reputation, :seeds,
  	:selecting_farm

  def initialize
  	@status = :title
  	@game_status = nil
  	@mainview = :farm
  	@mainmenu = :command

    @date = {year: 1, season: 0, week: 0}
    @money = 0
    @reputation = 0
    @seeds = SEEDS.clone
    @seeds = @seeds.map{|s|s.merge({amount: 0})}

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
  	p "select_command"
  	return if pos >= MAIN_MENU_TEXT.size
  	case MAIN_MENU_TEXT.to_a[pos][0]
  	when :farm
  	  @mainview = :farm
  	  @game_status = :none
  	when :cooperative
  	  @mainview = :shop
	  @game_status = :shop
  	when :part
  	  @debug_arg += 10
  	  gain_time
  	end
  end

  def select_seeds(pos)
  	p "select_seeds", pos
  	farm = @farm[@selecting_farm]
  	if pos > have_seeds.size
  	  return false
  	elsif pos == have_seeds.size
  	  @mainmenu = :command
  	  @game_status = :none
  	  @selecting_farm = -1
  	  return false
    end
  	farm[:plant] = have_seeds[pos]
  	farm[:plant].merge({prog: 0})
  	farm[:str] = have_seeds[pos][:name]
  	farm[:kind] = :plant
  	have_seeds[pos][:amount] -= 1
  	@game_status = :none
  	@mainmenu = :command
  	@selecting_farm = -1
  	@messages[0] = farm[:str]+"を植えた" 
  end

  def click_shop(pos)
  	seed = seeds_of_season[pos]
  	@seeds.each do |s|
      s[:amount] += 1 if s[:name] == seed[:name]
    end
  end

  def click_farm(pos)
    #Sound[:shovel].play
    farm = @farm[pos]
    if farm[:kind] == :wasteland
      farm[:prog] -= 1
      gain_time
      @messages[0] = "畑を開墾した"      
      @farm[pos].merge!({kind: :land, str: "空"}) if farm[:prog] == 0
    elsif farm[:kind] == :land 
      @mainmenu = :seeds
      @game_status = :planting
      @selecting_farm = pos
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
    @selecting_farm = -1
  end

  def seeds_of_season
  	SEEDS.select{|s|s[:planting].include?(@date[:season])}
  end

  def have_seeds
  	@seeds.select{|s|s[:amount] > 0}
  end

end