module Boosters
  
  class Booster
    
    def initialize
      @x = rand($game.width)
      @y = 0
      
      @img = nil
      
      @speed = 8
      
      @base = 0
      @rarity = 0
      
      @rectangle = Rectangle.new(0, 0, 64, 48)
    end
    
    def update(player_x, booster_speed)
      
      @x -= (player_x - $game.width / 2) * 0.2
      
      @y += @speed + booster_speed
      
      if @y > $game.height then
        reset()
      end
      
      @rectangle.x = @x
      @rectangle.y = @y
    end
    
    def draw(player_x = nil)
      @img.draw(@x, @y, 500) if @img != nil
      
      @x += (player_x - $game.width / 2) * 0.2 if player_x != nil
    end
    
    def collides?(rect)
      return true if @rectangle.collides?(rect)
      return false
    end
    
    def reset
      @y = -rand(@base..@rarity)
      @x = rand($game.width)
    end
    
  end
  
  class NormalBooster < Booster
    
    def initialize
      super()
      @img = Image.new("res/normal_booster.png")
      @base = 1000
      @rarity = 8000
      @y = -rand(@base..@rarity)
    end
    
  end
  
  class SuperBooster < Booster
    
    def initialize
      super()
      @img = Image.new("res/super_booster.png")
      @base = 3000
      @rarity = 12000
      @y = -rand(@base..@rarity)
    end
    
  end
  
  class HyperBooster < Booster
    
    def initialize
      super()
      @img = Image.new("res/hyper_booster.png")
      @base = 8000
      @rarity = 20000
      @y = -rand(@base..@rarity)
      @speed = 12
    end
    
  end
  
end