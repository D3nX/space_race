Star = Struct.new(:x, :y, :z, :speed, :width, :height)
Planet = Struct.new(:image, :x, :y, :z, :speed)

class StarAnimation
  
  def self.initialize(star_nmb)
    @@stars = []
    @@planets = []
      
    20.times do |i|
      @@planets << Planet.new(Image.new("res/planets/planet#{i + 1}.png"),
                              rand($game.settings.default_width),
                              -rand(1000..10000),
                              50,
                              rand(2..3)) if i + 1 != 8 and i + 1 != 9
    end
      
    x = 0
    y = 0
    star_nmb.times do |i|
      size = rand(1..10)
      @@stars << Star.new(x, y + (-20 + rand(40)), size * 10, size / 1.2, (size > 1) ? rand(2) + 1 : 1, size)
        
      x += 5 + rand(50)
      if x > $game.settings.default_width then
        x = -400
        y += 20 + rand(50)
        
        if y > $game.settings.default_height + 400
          break
        end
      end
    end
  end
  
  def self.draw(player_x = nil, booster_speed = 0)
    @@stars.each do |star|

      if player_x != nil then
        Gosu.draw_rect(star.x + -(player_x - $game.settings.default_width / 2) * (star.height * 0.1), star.y,
                      star.width, star.height,
                      Gosu::Color::WHITE, star.z) if star.x + -(player_x - $game.settings.default_width / 2) * (star.height * 0.1) + star.width > 0 and
                                                     star.x + -(player_x - $game.settings.default_width / 2) * (star.height * 0.1) < $game.settings.default_width
      else
        Gosu.draw_rect(star.x, star.y,
                      star.width, star.height,
                      Gosu::Color::WHITE, star.z) if star.x + star.width > 0 and
                                                     star.x < $game.settings.default_width
      end
      
      star.y += star.speed + booster_speed
      
      if star.y > $game.settings.default_height then
        star.x = -400 + rand($game.settings.default_width + 800)
        star.y = -star.size
      end
    end
    
    @@planets.each do |planet|
      
      if planet.y + planet.image.height * (planet.speed / 6.0) > 0
        if player_x != nil then
          planet.image.draw(planet.x + -(player_x - $game.settings.default_width / 2) * (planet.speed * 0.1),
                            planet.y,
                            planet.z,
                            planet.speed / 6.0,
                            planet.speed / 6.0)
        else
          planet.image.draw(planet.x, planet.y, planet.z, planet.speed / 6.0, planet.speed / 6.0)
        end
      end
      
      planet.y +=  planet.speed + booster_speed
            
      if planet.y > $game.settings.default_height then
        planet.x = rand($game.settings.default_width - 1)
        planet.y = -rand(1000..10000)
      end
    end
  end
  
end