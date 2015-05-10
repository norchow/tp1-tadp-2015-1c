require_relative 'partialblock'
require_relative 'base'

class Module
  attr_accessor :multi_method_definitions

  def multi_method_definitions
    @multi_method_definitions = @multi_method_definitions || Array.new
  end

  def multimethods
    self.multi_method_definitions.collect {|method| method.symbol}
  end

  def multi_method_definition(symbol)
    self.multi_method_definitions.find {|method| method.symbol == symbol }
  end

  def defines(symbol)
    self.multi_method_definitions.any?{|method| method.symbol == symbol }
  end

  def ancestors_who_define(symbol)
    self.ancestors.select {|ancestor| ancestor.defines(symbol)}
  end

  def local_definition_for(symbol)
    self.multi_method_definition(symbol)
  end

  def flattened_definitions_for(symbol)
    self.ancestors_who_define(symbol).collect {|ancestor| ancestor.local_definition_for(symbol)}
  end

  def multimethod(symbol)
    MultiMethod.new(symbol, flattened_definitions_for(symbol))
  end

  def partial_def (symbol, parameters_types, &method_body)
    if(self.defines(symbol))
      self.multi_method_definition(symbol).add_partial_definition(PartialBlock.new(parameters_types,&method_body))
    else
      self.add_multi_method(symbol, parameters_types, &method_body)
    end
  end

  def add_multi_method(symbol, parameters_types, &method_body)
    multi_method = MultiMethodDefinition.new(symbol)
    multi_method.add_partial_definition(PartialBlock.new(parameters_types,&method_body))
    self.multi_method_definitions << multi_method

    define_method symbol do |*arguments|
      self.class.multimethod(symbol).execute_for(*arguments,self)
    end

  end

end

class MultiMethodDefinition

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

class MultiMethod

  attr_accessor :symbol, :definitions, :current_partial_definition

  def initialize(symbol,definitions)
    self.symbol = symbol
    self.definitions = definitions
  end

  def definitions
    @definitions = @definitions || Array.new
  end

  def partial_definitions
    self.definitions.collect_concat{|definition| definition.partial_definitions}.uniq {|partial_def| partial_def.parameters_types}
  end

  def execute_following_definition(*arguments,receiver)

    execute_partial_definition(*arguments,(self.next_definition_for *arguments),receiver)
  end

  def execute_partial_definition(*arguments, partial_definition,receiver)

    self.current_partial_definition = partial_definition

    wrapper = Wrapper.new(receiver,self)

    wrapper.instance_exec(*arguments,&partial_definition)

  end

  def execute_for(*arguments, receiver)

    if (self.partial_definitions.none?{|definition| definition.matches *arguments})
      raise NonexistentMultimethodDefinitonError.new('Los argumentos no coinciden en cantidad y/o tipo con los parámetros de ninguna defincición para este método')
    end

    execute_partial_definition(*arguments,(self.closest_definition_for *arguments),receiver)

  end

  def next_definition_for(*arguments)
    self.matching_definitions_for(*arguments).at(self.matching_definitions_for(*arguments).find_index(current_partial_definition)+1)
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

  def is_defined_for_types? types
    self.partial_definitions.any?{|definition| definition.matches_types types}
  end

  def execute_strict_matching_for(param_types, *arguments, receiver)

    if (self.partial_definitions.none?{|definition| definition.parameters_types == param_types})
      raise NonexistentMultimethodDefinitonError.new('No hay una definición parcial para esos tipos')
    end

    execute_partial_definition(*arguments,(self.strict_definition_for(param_types,*arguments)),receiver)
  end
end

class NonexistentMultimethodDefinitonError < RuntimeError
end
