class Formation

  attr_accessor :monsters
  
  def initialize(path, base, rarity)
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
          @monsters << Monsters::BouncingShip.new(Vec2.new(x, y))
          @monsters[-1].fx = x
          @monsters[-1].y = y - next_y
        end
        

        x += Monsters::Monster::DEFAULT_WIDTH + 5
      end
      
      x = 0
      y += Monsters::Monster::DEFAULT_HEIGHT + 5
    end
  end
  
  def update(booster_speed)
    i = 0
    @monsters.each do |monster|
      monster.update(booster_speed)
      i += 1 if !monster.can_move
    end
    
    if i == @monsters.size then
      next_y = rand(@base..@rarity)
      @monsters.each do |monster|
        monster.y -= next_y
        monster.can_move = true
      end
    end
  end
  
  def draw
    @monsters.each do |monster|
      monster.draw()
    end
  end
  
  def each_monsters
    @monsters.each do |monster|
      yield monster
    end
  end
  
end