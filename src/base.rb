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


class Wrapper < BasicObject

  attr_accessor :true_receiver, :current_partial_definition, :current_multi_method

  def initialize(true_receiver,partial_def,multi_method)
    self.true_receiver = true_receiver
    self.current_partial_definition = partial_def
    self.current_multi_method = multi_method
  end

  def beis(*args)
    current_multi_method.execute_following_definition(*args,current_partial_definition,true_receiver)
  end

  def method_missing(symbol, *arguments)
    true_receiver.send(symbol,*arguments)
  end

end