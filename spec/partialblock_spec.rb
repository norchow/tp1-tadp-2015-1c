require 'rspec'
require_relative '../src/partialblock'

describe 'PartialBlock tests' do
  before(:all) do
    @helloBlock = PartialBlock.new([String]) do |who|
                    "Hello #{who}"
                  end
  end

  it 'Matches matchea con el tipo y cantidad que corresponde' do
    expect(@helloBlock.matches("a")).to be(true)
  end

  it 'Matches no matchea con el tipo que no corresponde' do
    expect(@helloBlock.matches(1)).to be(false)
  end

  it 'Matches no matchea con la cantidad que no corresponde' do
    expect(@helloBlock.matches("a", "b")).to be(false)
  end

  it 'Call devuelve lo que corresponde' do
    expect(@helloBlock.call("world!")).to eq("Hello world!")
  end

  it 'Call devuelve lo que corresponde' do
    expect {@helloBlock.call(1)}.to raise_error(ArgumentError)
  end

  it 'Bloque puede ser ejecutado con instancias de subtipos' do
    pairBlock = PartialBlock.new([Object, Object]) do |left, right|
      [left, right]
    end

    pairBlock.call("hello", 1) #Solo pruebo que corra
  end

  it 'Bloque parcial sin argumentos' do
    pi = PartialBlock.new([]) do
      3.14159265359
    end

    expect(pi.call()).to eq(3.14159265359)
    expect(pi.matches()).to be(true)
  end


  it 'Calcula bien la distancia entre argumento y su tipo' do
    distanceBlock = PartialBlock.new([Numeric]) do |num|
      num
    end
    expect(distanceBlock.distance_between(3,Numeric)).to eq(2)
    expect(distanceBlock.distance_between(3,Integer)).to eq(1)
  end

  it 'Calcula bien la distancia' do
    distanceBlock = PartialBlock.new([Numeric]) do |num|
      num
    end
    expect(distanceBlock.distance_to(3)).to eq(2)
    expect(distanceBlock.distance_to(3.0)).to eq(1)
  end


  it 'Calcula bien la distancia con 2 parametros' do

    distanceBlock1 = PartialBlock.new([Numeric,Integer]) do |num,num2|
      num
    end
    expect(distanceBlock1.distance_to(3.0,3)).to eq(3)
    expect(distanceBlock1.distance_to(3,3)).to eq(4)
  end
end