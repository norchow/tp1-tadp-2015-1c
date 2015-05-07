require_relative 'partialblock'

class Module
  attr_accessor :multi_methods

  def multi_methods
    @multi_methods = @multi_methods || Array.new
  end

  def partial_def (symbol, parameters_types, &method_body)
    if(self.defines(symbol))
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

  def executable_multi_method(symbol)
    multi_method = ExecutableMultiMethod.new(symbol)
    multi_method.partial_definitions = complete_unique_partial_definitions_for(symbol)
    return multi_method
  end

  def complete_partial_definitions_for(symbol)
    self.ancestors_who_define(symbol).collect_concat {|ancestor| ancestor.local_partial_definitions_for(symbol)}
  end

  def complete_unique_partial_definitions_for(symbol)
    self.complete_partial_definitions_for(symbol).uniq {|partial_def| partial_def.parameters_types}
  end

  def ancestors_who_define(symbol)
    self.ancestors.select {|ancestor| ancestor.defines(symbol)}
  end

  def local_partial_definitions_for(symbol)
    self.multimethod(symbol).partial_definitions
  end

  def defines(symbol)
    self.multi_methods.any?{|method| method.symbol == symbol }
  end

  def add_multi_method(symbol, parameters_types, &method_body)
    multi_method = MultiMethod.new(symbol)
    multi_method.add_partial_definition(PartialBlock.new(parameters_types,&method_body))
    self.multi_methods << multi_method

    define_method symbol do |*arguments|
        self.class.executable_multi_method(symbol).execute_for(*arguments,self)
    end

  end

end

class MultiMethod

  attr_accessor :symbol, :partial_definitions

  def initialize(symbol)
    self.symbol = symbol
  end

  def partial_definitions
    @partial_definitions = @partial_definitions || Array.new
  end

  def add_partial_definition(partial_definition)
    self.partial_definitions << partial_definition
  end

end

class ExecutableMultiMethod < MultiMethod

  def execute_for(*arguments, receiver)

    if (self.partial_definitions.none?{|definition| definition.matches *arguments})
      raise NonexistentMultimethodDefinitonError.new('Los argumentos no coinciden en cantidad y/o tipo con los parámetros de ninguna defincición para este método')
    end

    receiver.instance_exec(*arguments,&(self.closest_definition_for *arguments))
  end


  def closest_definition_for(*arguments)
    self.matching_definitions_for(*arguments).min_by {|definition| definition.distance_to *arguments}
  end

  def matching_definitions_for(*arguments)
    self.partial_definitions.select {|definition| definition.matches *arguments}
  end

  def strict_definition_for(param_types, *arguments)
    self.partial_definitions.find {|definition| definition.parameters_types == param_types}
  end

  def execute_strict_matching_for(param_types, *arguments, receiver)

    if (self.partial_definitions.none?{|definition| definition.parameters_types == param_types})
      raise NonexistentMultimethodDefinitonError.new('No hay una definición parcial para esos tipos')
    end

    receiver.instance_exec(*arguments,&(self.strict_definition_for(param_types,*arguments)))
  end
end

class NonexistentMultimethodDefinitonError < RuntimeError
end