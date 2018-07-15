class SettingsState
  
  def initialize
    
    @buttons = []
      
    default_button = Button.new(0, 0, 500, "res/button_n.png", "res/button_s.png")
    square_button = Button.new(0, 0, 500, "res/square_button_n.png", "res/square_button_s.png")
    
    3.times { @buttons << default_button.clone }
      
    6.times { @buttons << square_button.clone }
    
    # Default buttons
    @buttons[0].text = "Go Menu"
    @buttons[0].x = 5
    @buttons[0].y = $game.settings.default_height - @buttons[0].height - 5
    
    @buttons[1].text = "Disabled"
    @buttons[1].x = ($game.settings.default_width - $font.text_width("Graphics", 0.5)) / 2
    @buttons[1].y = 185

    @buttons[2].text = "Save"
    @buttons[2].x = $game.settings.default_width - @buttons[2].width - 5
    @buttons[2].y = $game.settings.default_height - @buttons[2].height - 5

    # Square buttons
    @buttons[3].text = "<"
    @buttons[3].x = ($game.settings.default_width - $font.text_width("Graphics", 0.5)) / 2
    @buttons[3].y = 280
    
    @buttons[4].text = ">"
    @buttons[4].x = ($game.settings.default_width - $font.text_width("Graphics", 0.5)) / 2 + 170
    @buttons[4].y = 280

    @buttons[5].text = "-"
    @buttons[5].x = 22
    @buttons[5].y = 185
    
    @buttons[6].text = "+"
    @buttons[6].x = 192
    @buttons[6].y = 185

    @buttons[7].text = "-"
    @buttons[7].x = 22
    @buttons[7].y = 280
    
    @buttons[8].text = "+"
    @buttons[8].x = 192
    @buttons[8].y = 280
    
    # Images
    @logo_d3nx = Image.new("res/Logo_D3nX.png", :retro => true)
    
    @bg = Image.new("res/settings_pad.png")
    
    # Variables initializing
    @clicked = false
    
    @next_state = nil
    
    @licenses = []
    
    Gosu::LICENSES.split("\n").each do |line|
      next if line == ""
      @licenses << line
    end
  end
  
  def update
    if Fader::faded_in? and @clicked then
      $game.state = @next_state
    end
    
    if @buttons[0].clicked?
      Fader::fade_in(10)
      @clicked = true
      @next_state = :menu
    elsif @buttons[1].clicked?
      @buttons[1].text = (@buttons[1].text == "Disabled") ? "Enabled" : "Disabled"
      
      $game.fullscreen = $game.settings.fullscreen = true if @buttons[1].text == "Enabled"
      $game.fullscreen = $game.settings.fullscreen = false if @buttons[1].text == "Disabled"
    elsif @buttons[2].clicked?

      $game.settings.fullscreen = (@buttons[1].text == "Enabled") ? true : false

      $game.save_settings
    end
    
    # Resolution
    if @buttons[3].clicked?
      $game.width -= 128 if $game.width > 640
      $game.height -= 72 if $game.height > 360
    elsif @buttons[4].clicked?
      $game.width += 128 if $game.width < 1920
      $game.height += 72 if $game.height < 1080
    end

    # Sfx volume
    if @buttons[5].clicked?
      $game.settings.music_volume -= 10 if $game.settings.music_volume > 0
      $game.apply_settings(true)
    elsif @buttons[6].clicked?
      $game.settings.music_volume += 10 if $game.settings.music_volume < 100
      $game.apply_settings(true)
    end

    # Music volume
    if @buttons[7].clicked?
      $game.settings.sfx_volume -= 10 if $game.settings.sfx_volume > 0
      $game.apply_settings(true)
    elsif @buttons[8].clicked?
      $game.settings.sfx_volume += 10 if $game.settings.sfx_volume < 100
      $game.apply_settings(true)
    end

  end
  
  def draw
    # Star Animation
    StarAnimation.draw
    
    # Settings title
    $font.draw("Settings",
               ($game.settings.default_width - $font.text_width("Settings")) / 2,
               15,
               500,
               1.0,
               1.0,
               Color::YELLOW)
    
    # Draw the pad  
    @bg.draw(15, 100, 500)
    
    # Draw the Gosu::LICENSES  
    for i in 0...@licenses.size
      $font.draw(@licenses[i],
                 22,
                 495 + i * 20,
                 500,
                 0.143,
                 0.2,
                 Color::YELLOW)
    end
    
    # Draw the category
    $font.draw("Sound",
               22,
               110,
               500,
               0.5,
               0.5,
               Color::YELLOW)
               
   $font.draw("Graphics",
              ($game.settings.default_width - $font.text_width("Graphics", 0.5)) / 2,
              110,
              500,
              0.5,
              0.5,
              Color::YELLOW)
                
    $font.draw("About",
               900,
               110,
               500,
               0.5,
               0.5,
               Color::YELLOW)

    # Sound stuff
    $font.draw("Music volume :",
      22,
      155,
      500,
      0.18,
      0.25)

    $font.draw("#{$game.settings.music_volume}%",
      90,
      200,
      500,
      0.30,
      0.4)

    $font.draw("SFX Volume :",
      22,
      255,
      500,
      0.18,
      0.25)

    $font.draw("#{$game.settings.sfx_volume}%",
      90,
      300,
      500,
      0.30,
      0.4)
     
    # Graphic stuff
    $font.draw("Fullscreen :",
               ($game.settings.default_width - $font.text_width("Graphics", 0.5)) / 2,
               155,
               500,
               0.18,
               0.25)
               
    $font.draw("Resolution : #{$game.width}x#{$game.height}",
               ($game.settings.default_width - $font.text_width("Graphics", 0.5)) / 2,
               255,
               500,
               0.18,
               0.25)
               
    # About stuff
    @logo_d3nx.draw(850, 160, 500, 2.0, 2.0)
    
    $font.draw("D3nX - Dreamvelopper",
               990,
               160,
               500,
               0.16,
               0.2)
               
    $font.draw("Space Race - 2018",
               990,
               175,
               500,
               0.16,
               0.2)
    
    # Drawing the buttons
    @buttons.each { |button| button.draw() }
  end
  
  def reset
    @clicked = false
    @next_state = nil
  end

  def set_volume; end
  
end