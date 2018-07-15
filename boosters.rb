module Boosters
  
  class Booster
    
    attr_reader :x, :y, :img
    
    def initialize(path)
      @x = rand($game.settings.default_width)
      @y = 0
      
      @img = Image.new(path)
      
      @speed = 8
      
      @base = 0
      @rarity = 0
      
      @rectangle = Rectangle.new(0, 0, @img.width, @img.height)
    end
    
    def update(player_x, booster_speed, can_go_down)
      
      @x -= (player_x - $game.settings.default_width / 2) * 0.2
      
      @y += @speed + booster_speed if can_go_down
      
      if @y > $game.settings.default_height then
        reset()
      end
      
      @rectangle.x = @x
      @rectangle.y = @y
     
    end
    
    def draw(player_x = nil)
      @img.draw(@x, @y, 500) if @img != nil and @y + @img.height > 0
      
      @x += (player_x - $game.settings.default_width / 2) * 0.2 if player_x != nil
    end
    
    def collides?(rect)
      return true if @rectangle.collides?(rect)
      return false
    end
    
    def reset
      @y = -rand(@base..@rarity)
      @x = rand($game.settings.default_width)
    end
    
  end
  
  class NormalBooster < Booster
    
    def initialize
      super("res/booster_normal.png")
      @base = 1000
      @rarity = 8000
      @y = -rand(@base..@rarity)
    end
    
  end
  
  class SuperBooster < Booster
    
    def initialize
      super("res/booster_super.png")
      @base = 3000
      @rarity = 12000
      @y = -rand(@base..@rarity)
    end
    
  end
  
  class HyperBooster < Booster
    
    def initialize
      super("res/booster_hyper.png")
      @base = 8000
      @rarity = 20000
      @y = -rand(@base..@rarity)
      @speed = 12
    end
    
  end
  
end