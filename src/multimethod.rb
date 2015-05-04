require_relative 'partialblock'

class Module
  attr_accessor :multi_methods

  def multi_methods
    @multi_methods = @multi_methods || Array.new
  end

  def get_multi_methods
    multi_methods + super.multi_methods
  end

  def partial_def (symbol, parameters_types, &method_body)
    if(self.multi_methods.any?{|method| method.symbol == symbol })
      self.multimethod(symbol).add_partial_definition(PartialBlock.new(parameters_types,&method_body))
    else
      self.add_multi_method(symbol, parameters_types, &method_body)
    end
  end

  def multimethod(symbol)
    self.multi_methods.find {|method| method.symbol == symbol }
  end

  def multimethods
    self.multi_methods.collect {|method| method.symbol}
  end

  def partial_definitions_for(symbol)
   unless self.multimethod(symbol).nil?
     self.multimethod(symbol).partial_definitions
   else
     []
   end
  end

  def add_multi_method(symbol, parameters_types, &method_body)
    self.multi_methods << MultiMethod.new(symbol,PartialBlock.new(parameters_types,&method_body),self)

    define_method symbol do |*arguments|
        self.class.multimethod(symbol).execute_for(*arguments,self)
    end

  end

end

class MultiMethod

  attr_accessor :symbol, :partial_definitions,:carrier_class

  def initialize(symbol, partial_definition,carrier_class)
    self.symbol = symbol
    self.add_partial_definition(partial_definition)
    self.carrier_class = carrier_class

  end

  def partial_definitions
    @partial_definitions = @partial_definitions || Array.new
  end

  def super_partial_definitions
    self.carrier_class.superclass.partial_definitions_for(symbol)
  end

  def total_partial_definitions
    self.partial_definitions.concat(self.super_partial_definitions)
  end

  def execute_for(*arguments, receiver)

    if (self.total_partial_definitions.none?{|definition| definition.matches *arguments})
      raise ArgumentError.new('Los argumentos no coinciden en cantidad y/o tipo con los parámetros de ninguna defincición para este método')
    end

    receiver.instance_exec(*arguments,&(self.closest_definition_for *arguments))
  end

  def add_partial_definition(partial_definition)
    self.partial_definitions << partial_definition
  end

  def closest_definition_for(*arguments)
    self.matching_definitions_for(*arguments).min_by {|definition| definition.distance_to *arguments}
  end

  def matching_definitions_for(*arguments)
    self.total_partial_definitions.select {|definition| definition.matches *arguments}
  end
end