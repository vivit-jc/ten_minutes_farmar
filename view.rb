class View

  def initialize(game, controller)
    @game = game
    @controller = controller

    @farmback = Image.new(FARM_SIZE, FARM_SIZE)
    @farmback.box(3, 3, FARM_SIZE-4, FARM_SIZE-4, WHITE)
    @farmback_selected = Image.new(FARM_SIZE, FARM_SIZE)
    @farmback_selected.box(6, 6, FARM_SIZE-7, FARM_SIZE-7, GREEN)
  end

  def draw
    draw_xy
    draw_debug
    case @game.status
    when :title
      draw_title
    when :game
      draw_game
    when :stats
      draw_stats
    end
  end

  def draw_game
    draw_header
    draw_main_menu
    case(@game.mainview)
    when :orders
      draw_orders
    when :market
      draw_market
    when :shop
      draw_shop
    else
      draw_farm
    end
    draw_crops
    draw_messages
    draw_part_timer if @game.part_action
  end

  def draw_part_timer
    Window.draw_font(10, PART_Y, "パートさんに指示を出しています(@30G) #{@game.part}/1", Font20) 
  end

  def draw_farm
    4.times do |x|
      3.times do |y|
        farm = @game.farm[x+y*4]
        Window.draw(30+(FARM_SIZE+10)*x,30+(FARM_SIZE+10)*y, @game.selecting_farm == x+y*4 ? @farmback_selected : @farmback)
        if farm[:kind] == :wasteland
          Window.draw_font(45+(FARM_SIZE+10)*x, 41+(FARM_SIZE+10)*y, "開墾", Font16)
          Window.draw_font(45+(FARM_SIZE+10)*x, 61+(FARM_SIZE+10)*y, "#{farm[:prog]}/#{farm[:max]}", Font16)
        elsif farm[:kind] == :land
          Window.draw_font(45+(FARM_SIZE+10)*x, 41+(FARM_SIZE+10)*y, farm[:str], Font16)
        elsif farm[:kind] == :plant
          Window.draw_font(41+(FARM_SIZE+10)*x, 41+(FARM_SIZE+10)*y, farm[:str], Font16)        
          Window.draw_font(41+(FARM_SIZE+10)*x, 41+(FARM_SIZE+10)*y+20, farm[:str2], Font16)
        end
      end
    end
  end

  def draw_orders
    orders = @game.orders
    orders.each_with_index do |o,i|
      if !@game.order.satisfy?(i)
        color = {color: GRAY}
      else
        color = mouseover_color(@controller.pos_order == i)
      end
      Window.draw_font(MAIN_VIEW_LIST_X, MAIN_VIEW_LIST_Y+24*i, "#{o[:crop]}", Font20, color)
      Window.draw_font(MAIN_VIEW_LIST_X+150, MAIN_VIEW_LIST_Y+24*i, "数量:#{o[:amount]}", Font20, color)
      Window.draw_font(MAIN_VIEW_LIST_X+230, MAIN_VIEW_LIST_Y+24*i, "期限:#{o[:waiting]}", Font20, color)
      Window.draw_font(MAIN_VIEW_LIST_X+300, MAIN_VIEW_LIST_Y+24*i, "#{o[:count]}/#{o[:max]}", Font20, color)
    end
  end

  def draw_market
    prices = @game.market.prices_in_season(@game.crops_of_season)
    prices.each_with_index do |p,i|
      color = mouseover_color(@controller.pos_market == i)
      Window.draw_font(MAIN_VIEW_LIST_X, MAIN_VIEW_LIST_Y+24*i, "#{p[:name]}", Font20, color)
      Window.draw_font(MAIN_VIEW_LIST_X+150, MAIN_VIEW_LIST_Y+24*i, "#{p[:price]}G", Font20, color)
    end
  end

  def draw_shop
    seeds = @game.seeds_of_season
    seeds.each_with_index do |s,i|
      amount = @game.seeds.find{|e|e[:name] == s[:name]}[:amount]
      Window.draw_font(MAIN_VIEW_LIST_X, MAIN_VIEW_LIST_Y+24*i, "#{s[:name]} x#{amount}", Font20, mouseover_color(@controller.pos_shop == i))
    end
    if @controller.pos_shop != -1
      s = seeds[@controller.pos_shop]
      Window.draw_font(220, 30, "#{s[:name]} #{s[:cost]}G", Font20)
      Window.draw_font(220, 54, "種まき "+s[:planting].map{|e|season_j(e)}.inject{|str,i|str+=(i+" ")}, Font20)
      str = s[:kind] == :flo ? "見ごろ " : "収穫 "
      if s[:kind] == :flu
        grow = "秋" 
      elsif s[:grow].size != 1 #一回植えて複数回採れる場合
        grow = s[:grow].map{|e|season_j(s[:planting][0]+e)}.inject{|str,i|str+=i+" "}
      else
        grow = s[:planting].map{|e|season_j(s[:grow][0]+e)}.inject{|str,i|str+=i+" "}
      end
        
      Window.draw_font(220, 78, "#{str} #{grow}", Font20)
      Window.draw_font(220, 102, "去年の売値 #{s[:value]}G", Font20) 
      if s[:kind] == :flu
        str = "※毎年収穫できる"
      elsif s[:grow].size > 1 && s[:kind] == :veg
        str = "※複数回収穫できる"
      else
        str = nil 
      end
      Window.draw_font(220, 135, str, Font20) if str 
          
    end
  end

  def draw_crops
    @game.have_crops.each_with_index do |c,i|
      Window.draw_font(10+140*(i%3), CROPS_Y+19*((i/3).floor), "#{c[:name]} x#{c[:amount]}", Font16)
    end
  end

  def draw_header
    date = @game.date
    Window.draw_font(640 - MAIN_MENU_WIDTH, 4, "#{date[:year]}年目 #{season_j(date[:season])} 第#{date[:week]+1}週", Font22)
    Window.draw_font(640 - MAIN_MENU_WIDTH+4, 33,"#{@game.money}G #{@game.reputation}rp", Font22)
    str = ""
    4.times do |i|
      str += date[:week] > i ? "●　" : "○　"
    end
    Window.draw_font(160, 4, str, Font22)
    
  end

  def draw_main_menu
    if @game.mainmenu == :seeds
      seeds = @game.have_seeds_of_season
      seeds.each_with_index do |h,i|
        Window.draw_font(640 - MAIN_MENU_WIDTH + 30, HEADER_HEIGHT+MENU_EACH_HEIGHT*i+5, h[:name]+" x"+h[:amount].to_s, Font20, mouseover_color(@controller.pos_main_menu == i)) 
      end
      Window.draw_font(640 - MAIN_MENU_WIDTH + 30, HEADER_HEIGHT+MENU_EACH_HEIGHT*seeds.size+5, "戻る", Font20, mouseover_color(@controller.pos_main_menu == seeds.size)) 
    else
      MAIN_MENU_TEXT.each_with_index do |(k,v),i|
        if(k == :part && @game.part_action)
          color = {color: YELLOW}
        else
          color = mouseover_color(@controller.pos_main_menu == i)
        end
        Window.draw_font(640 - MAIN_MENU_WIDTH + 30, HEADER_HEIGHT+MENU_EACH_HEIGHT*i+5, v, Font20, color) 
      end
    end
  end

  def draw_title
    Window.draw(0,0,Image[:title])
    Window.draw_font(20, 20, "10 MINUTES FARMER", Font50, {color: YELLOW})
    
    TITLE_MENU_TEXT.each_with_index do |menu,i|
      Window.draw_font(TITLE_MENU_X,TITLE_MENU_Y[i],menu,Font32,mouseover_color(@controller.pos_title_menu == i, YELLOW)) 
    end
  end

  def draw_messages
    @game.messages.each_with_index do |text, i|
      Window.draw_font(10, 480-MESSAGE_BOX_HEIGHT+i*22, text, Font20) if text
    end
  end

  def season_j(num)
    ["春","夏","秋","冬"][num%4]
  end

  def draw_xy
    Window.draw_font(0,0,Input.mouse_pos_x.to_s+" "+Input.mouse_pos_y.to_s,Font16)
  end

  def draw_debug
    Window.draw_font(0,20,@game.debug_arg.to_s,Font16)
  end

  def mouseover_color(bool, color=WHITE)
    return {color: GREEN} if bool
    return {color: color}
  end

end