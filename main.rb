require 'dxopal'
include DXOpal

require_remote './game.rb'
require_remote './view.rb'
require_remote './controller.rb'

BLACK = [0,0,0]
RED = [255,0,0]
YELLOW = [255,255,0]
CHEESE = [255,240,0]
GRAY = [90,90,90]
O_BLACK = [10,10,30]
DARK_BLUE = [25,25,230]
WHITE = [255,255,255]
CREAM = [255,240,210]
BAKED = [255,210,140]
BROWN = [230,70,70]
GREEN = [0,255,0]
DARKMAGENTA = [139,0,139]

FRAME = 15
TITLE_MENU_X = 30
TITLE_MENU_Y = [360,392,424]
TITLE_MENU_TEXT = ["START","STATS","ALL CLEAR"]

Font12 = Font.new(12)
Font16 = Font.new(16)
Font20 = Font.new(20)
Font28 = Font.new(28)
Font32 = Font.new(32)
Font50 = Font.new(50)
Font60 = Font.new(60)
Font100 = Font.new(100)

Window.height = 480
Window.width = 640

Image.register(:title, "./img/farm.jpg")

Window.load_resources do

  url = 'textdata.json'
  req = Native(`new XMLHttpRequest()`)
  req.overrideMimeType("text/plain")
  req.open("GET", url, false)
  req.send
  text_data = req.responseText
  TEXT = Native(`JSON.parse(text_data)`)

  game = Game.new
  controller = Controller.new(game)
  view = View.new(game,controller)

  Window.bgcolor = C_BLACK
  Window.loop do
    controller.input
    view.draw
  end
end
