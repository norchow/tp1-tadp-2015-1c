class PartialBlock

  attr_accessor :block, :parameters_types

  def initialize (some_parameters_types, &one_block)

    self.block = one_block
    self.parameters_types = some_parameters_types
  end

  def matches(*some_arguments)
    return (self.sameListsSize(some_arguments, self.parameters_types) && self.sameParametersType(*some_arguments))
  end

  def call(*some_parameters

    if (!self.matches(*some_parameters))
      raise ArgumentError.new('La cantidad de parametros informados no coinciden con la cantidad de parametros usados en el bloque')
    end

    self.block.call(some_parameters)
  end

  def sameListsSize(list1, list2)
    return list1.size == list2.size
  end

  def sameParametersType(*some_arguments)

    (some_arguments.zip self.parameters_types).all? do |argument, parameter_type| argument.is_a? parameter_type end

  end
end