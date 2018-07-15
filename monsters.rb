module Monsters
  
  class Monster
    
    DEFAULT_WIDTH = 93
    DEFAULT_HEIGHT = 101
    
    attr_accessor :x, :y, :fx, :fy, :speed, :can_move
    attr_reader :width, :height, :scale
    
    def initialize
      @x = 0
      @y = 0
      @fx = 0
      @fy = 0
      @width = nil
      @height = nil
      @scale = 1.0
      @speed = 0.0
      @can_move = true
      
      @@smokes_img ||= [
        Image.new("res/smoke_0.png"),
        Image.new("res/smoke_1.png"),
        Image.new("res/smoke_2.png")
      ]
      
      @current_smoke = 0
    end
    
    def update(player_x, booster_speed)
      raise "Error : Must implement it !"
    end
      
    def draw(player_x = nil)
      raise "Error : Must implement it !"
    end

    def reset
      raise "Error : Must implement it !"
    end

    def punch!(damage)
      raise "Error : Must implement it !"
    end
    
    def dead?
      raise "Error : Must implement it !"
    end
    
    def collides?(rect)
      raise "Error : Must implement it !"
    end
  end
  
  class BouncingShip < Monster
    
    def initialize(reset_pos)
      super()
      @reset_pos = reset_pos
      @@img ||= Image.new("res/spaceships/enemies/alien.png")
      @width = @@img.width
      @height = @@img.height
      @scale = 0.2
      
      @@lose_animation ||= Image.load_tiles("res/explosion.png", 64, 64, :retro => true).reverse
      @lose_time = 0
      @lose_limit = @@lose_animation.size * 10
      @lose_alpha = 0
      
      @speed = 1.0
      @y = -rand(500..1000)
      @time = 0
      
      @last_life = 5
      @life = 5
      
      @center_rect = Rectangle.new(0, 0, 32, 85)
      @left_rect = Rectangle.new(0, 0, 32, 32)
      @right_rect = Rectangle.new(0, 0, 32, 32)
    end
    
    def update(player_x, booster_speed)
      
      return if !@can_move

      @x -= (player_x - $game.settings.default_width / 2) * 0.2
      
      if @life > 0
        @time += 0.01
        @x = @fx + 300 + (Math::sin(@time) * 560)
        @y += @speed + booster_speed
      else
        if @lose_time == -1
          @y += 6 + booster_speed
        else
          @y += @speed + booster_speed
        end
      end
      
      if @y > $game.settings.default_height
        reset()
      end
      
      if @lose_time != -1 and
         @life <= 0 and
         @lose_time < @lose_limit
        
        @lose_time += 6
      elsif @life <= 0
        @current_smoke = rand(@@smokes_img.size) if @lose_time != -1
        @lose_time = -1
        @lose_alpha += 5 if @lose_alpha < 200
      end
      
      synchronize_rectangles()
    end
    
    def draw(player_x = nil)
      return if @y + @@img.height * @scale < 0 or
                @x + @@img.width * @scale < 0 or
                @x > $game.settings.default_width or
                !@can_move
      
      if @life > 0
        if @life == @last_life
          @@img.draw(@x, @y, 400, @scale, @scale)
        else
          @@img.draw(@x, @y, 400, @scale, @scale, Color::RED)
          @last_life = @life
        end
      else
        #puts @lose_time / 10.0 % @lose_animation.size
        if @lose_time != -1
          @@lose_animation[(@lose_time / 10 % @@lose_animation.size).to_i].draw(@x, @y, 400, 2.0, 2.0)
        else
          @@smokes_img[@current_smoke].draw(@x, @y, 400, 0.5, 0.5, Color.new(@lose_alpha, 255, 255, 255))
        end
      end

      @x += (player_x - $game.settings.default_width / 2) * 0.2 if player_x != nil
      
      return
      @center_rect.draw()
      @left_rect.draw()
      @right_rect.draw()
    end
    
    def punch!(damage)
      @life -= damage if @life > 0
    end
    
    def dead?
      return @life <= 0
    end
    
    def collides?(rect)
      return false if @life <= 0 or !@can_move
      return true if rect.collides?(@left_rect)
      return true if rect.collides?(@center_rect)
      return true if rect.collides?(@right_rect)
      return false
    end
    
    def synchronize_rectangles
      @center_rect.x = @x + 30
      @center_rect.y = @y
      
      @left_rect.x = @x
      @left_rect.y = @y + 45
      
      @right_rect.x = @x + (@width * 0.2 - @right_rect.width)
      @right_rect.y = @y + 45
    end
    
    def reset
      @x = @reset_pos.x
      @y = @reset_pos.y - $game.settings.default_height
      @lose_time = 0
      @life = 5
      @current_smoke = 0
      @lose_alpha = 0
      @time = 0
      @can_move = false
    end
    
  end

  class BlitzShip < Monster

    def initialize(reset_pos)

      super()

      @@img ||= Image.new("res/spaceships/enemies/blitzship.png")

      @reset_pos = reset_pos

      @scale = 0.45

      @x = reset_pos.x
      @y = reset_pos.y

      @reset_range = 1000...15000 # 100

      @life = 3
      @last_life = @life

      @punch_time = 0

      @rectangle = Rectangle.new(0, 0, @@img.width * @scale - 20, @@img.height * @scale - 20)
    end

    def update(player_x, booster_speed)

      return if !@can_move or dead?

      @x -= (player_x - $game.settings.default_width / 2) * 0.2

      @y += 5 + booster_speed

      @rectangle.x = @x + (@@img.width * @scale - @rectangle.width) / 2
      @rectangle.y = @y + (@@img.height * @scale - @rectangle.height) / 2

      reset() if @y > $game.settings.default_height
    end

    def draw(player_x = nil)
      return if !@can_move or dead?

      if @life == @last_life
        @@img.draw(@x, @y, 400, @scale, @scale)
      else
        @punch_time += 1

        if @punch_time < 5
          @@img.draw(@x, @y, 400, @scale, @scale, Color::RED)
        else
          @last_life = @life
          @punch_time = 0
        end
      end

      @x += (player_x - $game.settings.default_width / 2) * 0.2 if player_x != nil
    end

    def reset
      @x = @reset_pos.x
      @y = @reset_pos.y - $game.settings.default_height
      @can_move = false
      @life = 3
      @last_life = @life
      @punch_time = 0
    end

    def collides?(rect)
      return false if !@can_move or dead?
      return rect.collides?(@rectangle)
    end

    def punch!(damage)
      @life -= damage if @life > 0 and @punch_time == 0
    end

    def dead?
      return @life <= 0
    end

  end

end