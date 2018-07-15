Bonus = Struct.new(:x, :y, :text, :alpha)

class BonusText
  
  def initialize
    @bonus = []
  end
  
  def draw
    if @bonus.size > 0 then
      i = 0
      @bonus.each do |bonus|
        next if bonus == nil
        $font.draw(bonus.text, bonus.x, bonus.y, 500, 0.2, 0.2, Color.new(bonus.alpha, 255, 0, 0))
        bonus.alpha -= 2
        bonus.y -= 1
        @bonus.delete_at(i) if bonus.alpha < 1
        
        i += 1
      end
    end
    
  end
  
  def make(x, y, nmb)
    @bonus << Bonus.new(x, y, "+#{nmb}", 255)
  end
  
  def reset
    @bonus = []
  end
  
end