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
      
      @@smokes_img = [
        Image.new("res/smoke_0.png"),
        Image.new("res/smoke_1.png"),
        Image.new("res/smoke_2.png")
      ] if !defined? @@smokes_img
      
      @current_smoke = 0
    end
    
    def update
      raise "Error : Must implement it !"
    end
      
    def draw
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
      @@img = Image.new("res/alien.png") if !defined? @@img
      @width = @@img.width
      @height = @@img.height
      @scale = 0.2
      
      @@lose_animation = Image.load_tiles("res/explosion.png", 64, 64, :retro => true).reverse if !defined? @@lose_animation
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
    
    def update(booster_speed)
      
      return if !@can_move
      
      if @life > 0 then
        @time += 0.01
        @x = @fx + 300 + (Math::sin(@time) * 560)
        @y += @speed + booster_speed
      else
        if @lose_time == -1 then
          @y += 6 + booster_speed
        else
          @y += @speed + booster_speed
        end
      end
      
      if @y > $game.height then
        reset()
      end
      
      if @lose_time != -1 and
         @life <= 0 and
         @lose_time < @lose_limit then
        
        @lose_time += 6
      elsif @life <= 0 then
        @current_smoke = rand(@@smokes_img.size) if @lose_time != -1
        @lose_time = -1
        @lose_alpha += 5 if @lose_alpha < 200
      end
      
      synchronize_rectangles()
    end
    
    def draw
      return if @y + @@img.height * @scale < 0 or !@can_move
      
      if @life > 0 then
        if @life == @last_life then
          @@img.draw(@x, @y, 400, @scale, @scale)
        else
          @@img.draw(@x, @y, 400, @scale, @scale, Color::RED)
          @last_life = @life
        end
      else
        #puts @lose_time / 10.0 % @lose_animation.size
        if @lose_time != -1 then
          @@lose_animation[(@lose_time / 10 % @@lose_animation.size).to_i].draw(@x, @y, 400, 2.0, 2.0)
        else
          @@smokes_img[@current_smoke].draw(@x, @y, 400, 0.5, 0.5, Color.new(@lose_alpha, 255, 255, 255))
        end
      end
      
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
    
    def reset()
      @x = @reset_pos.x
      @y = @reset_pos.y - $game.height
      @lose_time = 0
      @life = 5
      @current_smoke = 0
      @lose_alpha = 0
      @time = 0
      @can_move = false
    end
    
  end
  
end