require "gosu"
require "./fader.rb"
require "./rectangle.rb"
require "./boosters.rb"
require "./staranimation.rb"
require "./button.rb"
require "./bullet.rb"
require "./monsters.rb"
require "./formation.rb"
require "./spaceship.rb"
require "./animation.rb"
require "./menustate.rb"
require "./countrystate.rb"
require "./gamestate.rb"
require "./gameoverstate.rb"

include Gosu

Vec2 = Struct.new(:x, :y)

# Global stuffs

$font = nil
$game = nil

$score = 0
$distance = 0

$menus_sample = Sample.new("res/menu_theme.ogg")
$menus_channel = nil

class Game < Gosu::Window
  
  attr_accessor :states
  
  def initialize
    super 1280, 720, false
    self.caption = "Space Race"
    $game = self
    
    $font = Font.new($game, "res/space age.ttf", 80)
    
    @state = :menu
    
    @states = {menu: MenuState.new(),
               country: CountryState.new(),
               game: GameState.new(),
               gameover: GameOverState.new()}
               
    @cam = Vec2.new(0, 0)
    
    @shake_pos = []

    Animation::initialize()
    Fader::initialize()
    
    Fader::make_black()
  end
  
  def update
    Fader::update()
    @states[@state].update()
    
    if @shake_pos.size > 0 then
      @cam = Vec2.new(@shake_pos[-1].x, @shake_pos[-1].y)
      @shake_pos.pop
    else
      @cam.x = 0
      @cam.y = 0
    end
  end
  
  def draw
    Gosu.translate(@cam.x, @cam.y) do
      @states[@state].draw()
    end
    Fader::draw()
  end
  
  def state=(new_state)
    @states[@state].reset()
    @state = new_state
    @states[new_state].reset()
  end
  
  def shake()
    40.times { @shake_pos << Vec2.new(-20 + rand(40), -20 + rand(40)) }
  end
  
  def stop_shaking!
    @shake_pos = []
  end
  
  def state
    return @state
  end
  
  def needs_cursor?
    return true
  end
  
  def self.as_seconds
    return Gosu.milliseconds / 1000
  end
  
end

Game.new().show()