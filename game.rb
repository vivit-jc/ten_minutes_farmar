class Game

require_remote './market.rb'
require_remote './order.rb'

  attr_reader :status, :game_status, :mainview, :mainmenu, :debug_arg, :messages, :farm, :date, :money, :reputation, :seeds,
  	:selecting_farm, :crops, :part, :part_action, :order, :orders, :market, :prices

  def initialize
  	@status = :title
  	@game_status = nil
  	@mainview = :farm
  	@mainmenu = :command

    @date = {year: 1, season: 0, week: 0}
    @money = 0
    @reputation = 0
    @seeds = SEEDS.clone
    @seeds = @seeds.map{|s|s.merge({amount: 0, picked: false})}
    @crops = SEEDS.map{|s|{name: s[:name], amount: 0}}
    @part = 0
    @part_action = false
    
    @order = Order.new(@crops)
    @orders = @order.orders
    @market = Market.new
    @prices = @market.prices

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
  	return if pos >= MAIN_MENU_TEXT.size
    sym = MAIN_MENU_TEXT.to_a[pos][0]
    @part_action = false if sym != :part

  	case sym
  	when :farm
  	  @mainview = :farm
  	  @game_status = :none
    when :orders
      @mainview = :orders
      @game_status = :orders
    when :market
      @mainview = :market
      @game_status = :market
  	when :cooperative
  	  @mainview = :shop
	    @game_status = :shop
  	when :part
  	  if @part_action
        @part_action = false
      else 
        @part_action = true
      end
  	end
  end

  def select_seeds(pos)
  	farm = @farm[@selecting_farm]
  	seeds = have_seeds_of_season
  	if pos > seeds.size
  	  return false
  	elsif pos == seeds.size
  	  @mainmenu = :command
  	  @game_status = :none
  	  @selecting_farm = -1
  	  return false
    end
  	farm[:plant] = seeds[pos].clone
  	farm[:plant].merge!({prog: 0})
  	farm[:str] = seeds[pos][:name]
  	farm[:str2] = grow_str(@selecting_farm)
  	farm[:kind] = :plant
  	seeds[pos][:amount] -= 1
  	@game_status = :none
  	@mainmenu = :command
  	@selecting_farm = -1
  	@messages[0] = farm[:str]+"を植えた"
    gain_time
  end

  def click_farm(farm_pos)
    #Sound[:shovel].play
    farm = @farm[farm_pos]
    if farm[:kind] == :wasteland
      farm[:prog] -= 1
      gain_time
      @messages[0] = "畑を開墾した"
      @farm[farm_pos].merge!({kind: :land, str: "空"}) if farm[:prog] == 0
    elsif farm[:kind] == :land 
      @mainmenu = :seeds
      @game_status = :planting
      @selecting_farm = farm_pos
    elsif farm[:kind] == :plant
      case grow_status(farm_pos)
      when :pickable 
      	pick_crops(farm_pos)
      when :picked
      	@messages[0] = "そこは既に収穫した"
      when :growing
      	@messages[0] = "収穫にはまだ早い"
      when :wasted
      	clean_farm(farm_pos)
  	    @messages[0] = "畑を片付けた"
      end
    end
  end

  def click_order(pos)
    unless @order.satisfy?(pos)
      @messages[0] = "受注できる量の品物が無い"
      return 
    end

    order = @orders[pos]
    @order.fill_order(pos)
    @reputation += order[:rep]
    @messages[0] = "ok"
  end

  def click_market(pos)
    crop_name = crops_of_season[pos]
    crop = @crops.find{|c|c[:name] == crop_name}
    if crop[:amount] < 1
      @messages[0] = "品物が無い"
      return
    end
    price = @prices.find{|p|p[:name] == crop_name}
    crop[:amount] -= 1
    @money += price[:price]
    @messages[0] = ""
  end

  def click_shop(pos)
    seed = seeds_of_season[pos]
    @seeds.each do |s|
      s[:amount] += 1 if s[:name] == seed[:name]
    end
  end

  def pick_crops(farm_pos)
  	farm = @farm[farm_pos]
  	plant = farm[:plant]
  	crop = @crops.find{|c|c[:name] == plant[:name]}
  	crop[:amount] += 10
  	@messages[0] = plant[:name]+"を収穫した"
  	if plant[:grow].size == 1
      clean_farm(farm_pos) 
    else
      plant[:picked] = true
      farm[:str2] = grow_str(farm_pos)
    end
  	gain_time
  end

  def gain_time
    if @part_action
      @part += 1
      return
    end

  	@date[:week] += 1
  	if @date[:week] == 4
	    @date[:week] = 0
	    @date[:season] += 1
	    @farm.each_with_index do |farm,i|
	  	  if farm[:kind] == :plant
	  	    farm[:plant][:prog] += 1
	  	    farm[:plant][:picked] = false
	  	    farm[:str2] = grow_str(i)
	  	  end
	    end
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

  def seeds_of_season(season = @date[:season])
  	SEEDS.select{|s|s[:planting].include?(season)}
  end

  def crops_of_season(season = @date[:season])
    #名前の文字列配列を返す
    #ハッシュ配列ではないことに注意！（名前文字列から検索して目的のハッシュ配列を作るため）
    crops = []
    SEEDS.each do |s|
      if s[:kind] == :flu
        crops.push s[:name] if season == 2
      elsif s[:planting].size >= 2
        grow = s[:planting].map{|g|(g+s[:grow][0])%4}
        crops.push s[:name] if grow.include?(season)
      elsif s[:grow].size >= 2
        grow = s[:grow].map{|g|(g+s[:planting][0])%4}
        crops.push s[:name] if grow.include?(season)
      else
        crops.push s[:name] if (s[:grow][0]+s[:planting][0])%4 == season
      end
    end

    return crops
  end

  def have_seeds
  	@seeds.select{|s|s[:amount] > 0}
  end

  def have_seeds_of_season
  	@seeds.select{|s|s[:amount] > 0 && s[:planting].include?(@date[:season])}
  end

  def have_crops
  	@crops.select{|s|s[:amount] > 0}
  end

  def clean_farm(farm_pos)
    farm = @farm[farm_pos]
  	farm[:plant] = {}
  	farm[:str] = "空"
  	farm[:kind] = :land
  end 

  def grow_status(farm_pos)
  	plant = @farm[farm_pos][:plant]
  	if plant[:picked]
  	  return :picked
    elsif plant[:grow].include?(plant[:prog])
  	  return :pickable
  	elsif plant[:grow].find{|e|e > plant[:prog]}
  	  return :growing
  	else 
  	  return :wasted
    end
  end

  def grow_str(farm_pos)
    case grow_status(farm_pos)
    when :picked
      return "収穫済み"
    when :pickable
  	  return "収穫可"
  	when :growing
  	  return "生育中"
  	when :wasted
  	  return "廃棄"
    end
  end
end