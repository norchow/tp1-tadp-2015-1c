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

  def add_multi_method(symbol, parameters_types, &method_body)
    self.multi_methods << MultiMethod.new(symbol,PartialBlock.new(parameters_types,&method_body))

    define_method symbol do |*arguments|
      begin
        self.class.multimethod(symbol).execute_for *arguments,self
      rescue
        self.class.superclass.new.send(symbol,*arguments)
      end
    end

  end

end

class MultiMethod

  attr_accessor :symbol, :partial_definitions

  def initialize(symbol, partial_definition)
    self.symbol = symbol
    self.add_partial_definition(partial_definition)
  end

  def partial_definitions
    @partial_definitions = @partial_definitions || Array.new
  end

  def execute_for(*arguments, receiver)

    if (self.partial_definitions.none?{|definition| definition.matches *arguments})
      raise ArgumentError.new('Los argumentos no coinciden en cantidad y/o tipo con los parámetros de ninguna defincición para este método')
    end

    receiver.instance_exec *arguments,&(self.closest_definition_for *arguments)
  end

  def add_partial_definition(partial_definition)
    self.partial_definitions << partial_definition
  end

  def closest_definition_for(*arguments)
    self.matching_definitions_for(*arguments).min_by {|definition| definition.distance_to *arguments}
  end

  def matching_definitions_for(*arguments)
    self.partial_definitions.select {|definition| definition.matches *arguments}
  end
end