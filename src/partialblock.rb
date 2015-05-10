class Class
  def is_descended?(type)
    self.ancestors.include? type
  end
end

class PartialBlock < Proc

  attr_accessor :block, :parameters_types

  def initialize (some_parameters_types, &one_block)

    self.block = one_block
    self.parameters_types = some_parameters_types
  end

  def matches(*some_arguments)
    self.matches_types some_arguments.collect{|argument| argument.class}
  end

  def matches_types(some_types)
    self.same_lists_size?(some_types, self.parameters_types) && self.parameters_types_match?(some_types)
  end

  def call(*some_parameters)

    if (!self.matches(*some_parameters))
      raise ArgumentError.new('La cantidad de parametros informados no coinciden con la cantidad de parametros usados en el bloque')
    end

    self.block.call(*some_parameters)
  end

  def same_lists_size?(list1, list2)
    return list1.size == list2.size
  end

  def parameters_types_match?(some_types)
    (some_types.zip self.parameters_types).all? do |type, parameter_type| type.is_descended? parameter_type end
  end

  def distance_to(*arguments)
    ((arguments.zip self.parameters_types).collect { |argument,parameter_type| self.distance_between(argument,parameter_type)*(parameters_types.find_index(parameter_type)+1)}).reduce(:+)
  end

  def distance_between(argument,parameter_type)
    argument.class.ancestors.index(parameter_type)
  end

end