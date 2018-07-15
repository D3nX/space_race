module Fader
  
  def self.initialize
    @@alpha = 0
    @@color = Color.new(0, 0, 0, 0)
    
    @@faded_in = false
    @@faded_out = false
    
    @@fade = 0
    
    @@speed = 2
  end
  
  def self.update
    if @@fade == 1 then
      @@faded_out = false
      if @@alpha < 255
        @@alpha += @@speed
      else
        @@faded_in = true
        @@fade = 0
      end
      @@color = Color.new(@@alpha, 0, 0, 0)
    elsif @@fade == 2 then
      @@faded_in = false
      if @@alpha > 0
        @@alpha -= @@speed
      else
        @@faded_out = true
        @@fade = 0
      end
      @@color = Color.new(@@alpha, 0, 0, 0)
    end
  end
  
  def self.draw
    # puts @@alpha
    return if @@alpha == 0
    Gosu.draw_rect(0, 0, $game.settings.default_width, $game.settings.default_height, @@color, 500)
  end
  
  def self.reset
    self.initialize()
  end
  
  def self.fade_in(speed)
    @@speed = speed
    @@fade = 1 # 1 -> Make darker
  end
  
  def self.fade_out(speed)
    @@speed = speed
    @@fade = 2 # 2 -> Make lighter
  end
  
  def self.faded_in?
    return @@faded_in
  end
  
  def self.faded_out?
    return @@faded_out
  end
  
  def self.make_black
    @@alpha = 255
    @@color = Color.new(255, 0, 0, 0)
    @@faded_in = true
    @@faded_out = false
    @@speed = 0
  end
  
end