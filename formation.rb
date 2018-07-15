class Formation

  attr_accessor :monsters
  
  def initialize(path, base, rarity, monster_class)

    raise "Error: \"monster_class\" is not a type!" if monster_class.class != Class

    file = File.open(path,"r")
    
    @base = base
    
    @rarity = rarity
    
    @monsters = []
    
    next_y = rand(base..rarity)
      
    x = 0
    y = 0

    file.each_line do |line|
      args = line.split(",")
      
      args.each do |arg|
        if arg.to_i == 1 then
          @monsters << monster_class.new(Vec2.new(x, y))
          @monsters[-1].fx = x
          @monsters[-1].y = y - next_y
        end

        x += Monsters::Monster::DEFAULT_WIDTH + 5
      end
      
      x = 0
      y += Monsters::Monster::DEFAULT_HEIGHT + 5
    end
  end
  
  def update(player_x, booster_speed)
    i = 0
    @monsters.each do |monster|
      monster.update(player_x, booster_speed)
      i += 1 if !monster.can_move
    end
    
    if i == @monsters.size then
      next_y = rand(@base..@rarity)
      next_x = rand($game.settings.default_width)
      @monsters.each do |monster|
        monster.x += next_x
        monster.y -= next_y
        monster.can_move = true
      end
    end
  end
  
  def draw(player_x = nil)
    @monsters.each do |monster|
      monster.draw(player_x)
    end
  end
  
  def each_monsters
    @monsters.each do |monster|
      yield monster
    end
  end
  
end