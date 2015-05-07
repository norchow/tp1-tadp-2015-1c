require_relative 'partialblock'
require_relative 'multimethod'

class Object
  def respond_to?(symbol,private,types)
    self.class.executable_multi_method(symbol).is_defined_for_types?(types)
  end
end