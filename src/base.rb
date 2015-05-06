require_relative 'multimethod'

class BaseMultiMethod
  attr_accessor :receiver
  def initialize(receiver)
    self.receiver = receiver
  end
  def method_missing(sym, *args)
    param_types = args.first
    arguments = args[1..-1] #Get args tail
    self.receiver.class.executable_multi_method(sym).execute_strict_matching_for(param_types, arguments, receiver)
  end
end
class Object
  def base
    BaseMultiMethod.new(self)
  end
end
