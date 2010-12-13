class Noodle
  
  attr_accessor :shape, :cooked, :tasty
  
  def initialize
    @shape = "farfalla"
    @cooked = false
    @tasty = false
  end
  
  def cook
    @cooked = true
  end

  def good
    @tasty = true
  end
  
  def transform(shape)
    @shape = shape
  end
  
end
