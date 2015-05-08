require_relative 'multimethod'

class BaseMultiMethod
  attr_accessor :receiver
  def initialize(receiver)
    self.receiver = receiver
  end
  def method_missing(sym, *args)
    param_types = args.first
    arguments = args.drop(1)
    self.receiver.class.multimethod(sym).execute_strict_matching_for(param_types, arguments, receiver)
  end
end
class Object
  def base
    BaseMultiMethod.new(self)
  end
end
