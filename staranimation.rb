Star = Struct.new(:x, :y, :z, :speed, :size)
Planet = Struct.new(:image, :x, :y, :z, :speed)

class StarAnimation
  
  def self.initialize(star_nmb)
    @@stars = []
    @@planets = []
      
    20.times do |i|
      @@planets << Planet.new(Image.new("res/planets/planet#{i + 1}.png"),
                              rand($game.width),
                              -rand(1000..10000),
                              50,
                              rand(2..3)) if i + 1 != 8 and i + 1 != 9
    end
      
    x = 0
    y = 0
    star_nmb.times do |i|
      size = rand(1..10)
      @@stars << Star.new(x, y + (-20 + rand(40)), size * 10, size / 1.2, size)
        
      x += 5 + rand(50)
      if x > $game.width then
        x = -400
        y += 20 + rand(50)
        
        if y > $game.height + 400
          break
        end
      end
    end
  end
  
  def self.draw(player_x = nil, booster_speed = 0)
    @@stars.each do |star|
      if player_x != nil then
        Gosu.draw_line(star.x + -(player_x - $game.width / 2) * (star.size * 0.1), star.y, Color::WHITE,
                       star.x + -(player_x - $game.width / 2) * (star.size * 0.1), star.y + star.size, Color::WHITE,
                       star.z)
      else
        Gosu.draw_line(star.x, star.y, Color::WHITE,
                       star.x, star.y + star.size, Color::WHITE,
                       star.z)
      end
      
      star.y += star.speed + booster_speed
      
      if star.y > $game.height then
        star.x = -400 + rand($game.width + 800)
        star.y = -star.size
      end
    end
    
    @@planets.each do |planet|
      
      if player_x != nil then
        planet.image.draw(planet.x + -(player_x - $game.width / 2) * (planet.speed * 0.1),
                          planet.y,
                          planet.z,
                          planet.speed / 6.0,
                          planet.speed / 6.0)
      else
        planet.image.draw(planet.x, planet.y, planet.z, planet.speed / 6.0, planet.speed / 6.0)
      end
      
      planet.y +=  planet.speed + booster_speed
            
      if planet.y > $game.height then
        planet.x = rand($game.width - 1)
        planet.y = -rand(1000..10000)
      end
    end
  end
  
  private
  
  def self.draw_circle(cx, cy, r) 
    color = Color::WHITE
    0.step(360, 10) do |a1|
      a2 = a1 + 10
      Gosu.draw_line(cx + Gosu.offset_x(a1, r), cy + Gosu.offset_y(a1, r), color, cx + Gosu.offset_x(a2, r), cy + Gosu.offset_y(a2, r), color, 9999)
    end
  end
  
end