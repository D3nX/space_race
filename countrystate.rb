class  CountryState
  
  def initialize
    @buttons = [Button.new(0, 0, 500, "res/american_propaganda_n.png", "res/american_propaganda_s.png"),
                Button.new(0, 0, 500, "res/ussr_propaganda_n.png", "res/ussr_propaganda_s.png"),
                Button.new(0, 0, 500, "res/button_n.png", "res/button_s.png")]
                
    @buttons[0].x = $game.width / 2 - @buttons[0].width - 75
    @buttons[0].y = 100
    
    @buttons[1].x = $game.width / 2 + 75
    @buttons[1].y = 100
    
    @buttons[2].text = "Go Menu"
    @buttons[2].x = 5
    @buttons[2].y = $game.height - @buttons[2].height - 5
    
    @songs = [Song.new("res/United States of America National Anthem (Instrumental).mp3"),
              Song.new("res/Soviet_Anthem_Instrumental_1955.mp3")]
              
    @songs.each { |song| song.volume = 0.2 }
              
    @next_country = nil
    
    @go_to_menu = false
    
  end
  
  def update
    
    if Fader::faded_in? and !@go_to_menu then
      Fader::fade_out(10)
    elsif Fader::faded_in? and @go_to_menu then
      $game.state = :menu
    end
    
    if @buttons[2].clicked? then
      Fader::fade_in(10)
      @go_to_menu = true
    end
    
    i = 0
    @buttons.each do |button|
      
      if button.hover? and i < 2 and !@go_to_menu and $game.state != :menu then
        @songs[i].play() if !@songs[i].playing?
      else
        @songs[i].stop() if i < 2
      end
      
      if button.clicked? and i < 2 then
        Fader::fade_in(10)
        if i == 0 then
          @next_country = :usa
          # $game.states[:game].set_spaceship_country(:usa)
        else
          @next_country = :ussr
          # $game.states[:game].set_spaceship_country(:ussr)
        end
      end
      i += 1
    end
        
    if Fader::faded_in?() and @next_country != nil then
      $menus_channel.stop()
      $game.states[:game].set_spaceship_country(@next_country)
      $game.state = :game
    end
    
  end
  
  def draw
    StarAnimation.draw()
    $font.draw("Choose your country :",
               ($game.width - $font.text_width("Choose your country :", 0.5)) / 2,
               10,
               500, 0.5, 0.5,
               Color::RED)
    i = 0
    @buttons.each do |button|
      button.draw()
      i += 1
    end
    
  end
  
  def reset
    @next_country = nil
    @go_to_menu = false
    @songs.each { |song| song.stop() }
  end
  
end
