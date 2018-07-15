require "gosu"
require_relative "spritemanager"
require_relative "bonustext"
require_relative "fader"
require_relative "rectangle"
require_relative "boosters"
require_relative "asteroid"
require_relative "staranimation"
require_relative "button"
require_relative "bullet"
require_relative "monsters"
require_relative "formation"
require_relative "spaceship"
require_relative "animation"
require_relative "selectorbar"
require_relative "progressbar"
require_relative "menustate"
require_relative "settingsstate"
require_relative "countrystate"
require_relative "selectorstate"
require_relative "gamestate"
require_relative "gameoverstate"
require_relative "scorestate"
require_relative "teststate"

include Gosu

Vec2 = Struct.new(:x, :y)
Settings = Struct.new(:music_volume, :sfx_volume, :fullscreen, :default_width, :default_height, :mouse_x, :mouse_y)

# Global stuffs

$font = nil
$game = nil

$menus_sample = Sample.new("res/menu_theme.ogg")
$menus_channel = nil

class Game < Gosu::Window

  attr_accessor :states, :distance, :score, :settings

  def initialize
    
    super 1280, 720, false
    
    self.caption = "Space Race"
    
    $game = self
    
    $font = Font.new($game, "res/space age.ttf", 80)
    
    @settings = Settings.new(100, 100, false, self.width, self.height, 0, 0)

    load_settings()

    @state = :menu

    @states = {menu: MenuState.new(),
               settings: SettingsState.new(),
               country: CountryState.new(),
               selector: SelectorState.new(),
               game: GameState.new(),
               gameover: GameOverState.new(),
               scorestate: ScoreState.new(),
               teststate: TestState.new()}

    @cam = Vec2.new(0, 0)

    @shake_pos = []

    @distance = 0.0
    @score = 0.0

    Animation::initialize()
    
    Fader::initialize()

    Fader::make_black()

    apply_settings()
    
    @changing_state = false

    # Load every sprite needed in the sprite manager
    SpriteManager.initialize()

    SpriteManager.add("Soyouz X9", "res/spaceships/soviet/soviet_0.png")
    SpriteManager.add("Soyouz X10", "res/spaceships/soviet/soviet_1.png")
    SpriteManager.add("Nasa Falcon I", "res/spaceships/usa/usa_ship_0.png")
    SpriteManager.add("Nasa Falcon II", "res/spaceships/usa/usa_ship_1.png")
    
  end

  def update

    self.state = :teststate if button_down?(KB_ESCAPE)

    @settings.mouse_x = self.mouse_x / (self.width.to_f / @settings.default_width)
    @settings.mouse_y = self.mouse_y / (self.height.to_f / @settings.default_height)
    
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
    Gosu.scale(self.width.to_f / @settings.default_width, self.height.to_f / @settings.default_height) do
      Gosu.translate(@cam.x, @cam.y) do
        @states[@state].draw()
      end
      Fader::draw()
    end
  end

  def state=(new_state)
    @states[@state].reset()
    @state = new_state
    @states[new_state].reset()
    
    @changing_state = true
  end

  def shake
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

  # Settings stuff
  def load_settings

    file = File.new("data/settings.cfg", "r")

    file.each_line do |line|
      next if line[0] == "#"

      if line.include?("volume") and not line.include?("sfx_volume")
        @settings.music_volume = line.split("=")[1].to_i
      elsif line.include?("sfx_volume")
        @settings.sfx_volume = line.split("=")[1].to_i
      elsif line.include?("fullscreen")
        @settings.fullscreen = (line.split("=")[1] == "true") ? true : false
      elsif line.include?("width")
        self.width = line.split("=")[1].to_i
      elsif line.include?("height")
        self.height = line.split("=")[1].to_i
      end
    end

  end

  def save_settings

    file = File.new("data/settings.cfg", "w")

    file.truncate(0)
    file.write("# Settings of the game\n")
    file.write("width=#{self.width}\n")
    file.write("height=#{self.height}\n")
    file.write("volume=#{@settings.music_volume}\n")
    file.write("sfx_volume=#{@settings.sfx_volume}\n")
    file.write("fullscreen=#{@settings.fullscreen}")

  end

  def apply_settings(only_volume = false)
    if not only_volume
      @states.each { |_, state| state.set_volume }
      self.fullscreen = @settings.fullscreen
    else
      @states.each { |_, state| state.set_volume }
    end
  end

end

Game.new().show()
