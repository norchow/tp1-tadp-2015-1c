class PartialBlock

  attr_accessor :block, :parameters_types

  def initialize (some_parameters_types, &one_block)

    self.block = one_block
    self.parameters_types = some_parameters_types
  end

  def matches(*some_parameters)
    return (self.sameListsSize(some_parameters, self.parameters_types) && self.sameParametersType(*some_parameters))
  end

  def call(*some_parameters)

    if (!self.matches(*some_parameters))
      raise ArgumentError.new('La cantidad de parametros informados no coinciden con la cantidad de parametros usados en el bloque')
    end

    self.block.call(some_parameters)
  end

  def sameListsSize(list1, list2)
    return list1.size == list2.size
  end

  def sameParametersType(*some_parameters)

    i = 0
    while i < some_parameters.length  do
      parameter_type = self.parameters_types[i]
      parameter = some_parameters[i]

      if (!parameter.is_a? parameter_type)
        return false
      end

      i += 1
    end

    return true
  end
end