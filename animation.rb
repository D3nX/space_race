module Animation
  
  def self.initialize()
    @@animation = nil
    
    @@speed = 0.3
    @@vspeed = 0.0
    
    @@x = 0
    @@y = -128
    
    @@color = nil
    
    @@filter_color = nil
    
    @@anim_state = 0
    
    @@star_image = Image.new("res/lsd_star.png")
    
    @@star_x = 0
    
    @@lsd_filter = Image.new("res/lsd_filter.png")
    
    @@lsd_filter_color = Color.new(0, 255, 255, 255)
    
    @@lsd_filter_angle = 0.0
  end
  
  def self.launch(animation)
    
    return if @@animation != nil
    
    @@animation = animation
    
    if @@animation == :normal_booster then
      @@color = Color.new(128, 128, 128, 128)
      @@filter_color = Color.new(0, 0, 0, 0)
      @@anim_state = 0
    elsif @@animation == :super_booster then
      @@color = Color.new(128, 32, 255, 32)
      @@filter_color = Color.new(0, 0, 0, 0)
      @@anim_state = 0
    elsif @@animation == :hyper_booster then
      @@color = Color.new(128, 255, 255, 0)
      @@filter_color = Color.new(0, 0, 0, 0)
      @@anim_state = 0
    end
  end
  
  def self.update
    if @@animation != nil then
      
      if @@anim_state == 0 then
        if @@y < $game.settings.default_height / 4 then
          @@vspeed += @@speed if @@vspeed < 7.0
        else
          @@vspeed -= @@speed if @@vspeed > 0.6
          @@vspeed = 0.6 if @@vspeed <= 0.6
        end
        
        if @@y + 64 > $game.settings.default_height / 2
          @@anim_state = 1
        end
        
        @@filter_color = Color.new(@@filter_color.alpha + 2, 0, 0, 0) if @@filter_color.alpha < 150
        @@y += @@vspeed
        
        if @@lsd_filter_color.alpha < 255 then
          @@lsd_filter_color = Color.new(@@lsd_filter_color.alpha + 5, 255, 255, 255)
        end
      elsif @@anim_state == 1 then
        @@vspeed += @@speed
        @@y += @@vspeed
        
        @@filter_color = Color.new(@@filter_color.alpha - 3, 0, 0, 0) if @@filter_color.alpha > 0
        
        if @@y > $game.settings.default_height then
          Animation::reset()
        end
        
        if @@lsd_filter_color.alpha > 0 then
          @@lsd_filter_color = Color.new(@@lsd_filter_color.alpha - 5, 255, 255, 255)
        end
      end
      
      if @@animation == :hyper_booster then
        @@star_x += 4
        @@lsd_filter_angle += 4.0
      end
      
    end
  end
  
  def self.draw
    if @@animation != nil then
      Gosu.draw_rect(0, 0, $game.settings.default_width, $game.settings.default_height, @@filter_color, 500)
      if @@animation == :normal_booster then
        Gosu.draw_rect(@@x, @@y, $game.settings.default_width, 128, @@color, 500)
        $font.draw("Normal Booster",
                   @@x + ($game.settings.default_width - $font.text_width("Normal Booster")) / 2,
                   @@y + (128 - $font.height) / 2,
                   500)
      elsif @@animation == :super_booster then
        Gosu.draw_rect(@@x, @@y, $game.settings.default_width, 128, @@color, 500)
        $font.draw("Super Booster",
                   @@x + ($game.settings.default_width - $font.text_width("Super Booster")) / 2,
                   @@y + (128 - $font.height) / 2,
                   500)
      elsif @@animation == :hyper_booster then
        # puts @@lsd_filter_angle
        @@lsd_filter.draw_rot($game.settings.default_width / 2, $game.settings.default_height / 2, 500,
                              @@lsd_filter_angle,
                              0.5,
                              0.5,
                              1.0,
                              1.0,
                              @@lsd_filter_color) 
        ($game.settings.default_width / 128 + 1).times do |i|
          x = @@star_x + i * 128
          if x > $game.settings.default_width then
            x = @@star_x + i * 128 - $game.settings.default_width - 128
          end
          @@star_image.draw(x, @@y, 500)
        end
        Gosu.draw_rect(@@x, @@y, $game.settings.default_width, 128, @@color, 500)
                       $font.draw("Hyper Booster",
                       @@x + ($game.settings.default_width - $font.text_width("Hyper Booster")) / 2,
                       @@y + (128 - $font.height) / 2,
                       500)
      end
    end
  end
  
  def self.reset
    @@speed = 0.3
    @@vspeed = 0.0
    
    @@x = 0
    @@y = -128
    
    @@color = nil
    
    @@filter_color = nil
    
    @@anim_state = 0
    
    @@animation = nil
    
    @@star_x = 0
    
    @@lsd_filter_color = Color.new(0, 255, 255, 255)
    
    @@lsd_filter_angle = 0.0
  end
  
end