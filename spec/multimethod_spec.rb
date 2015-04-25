require 'rspec'
require_relative '../src/multimethod'

describe 'MultiMethod tests' do

  before(:all) do
    class A
      extend MultiMethod

      partial_def :concat, [String, String] do |s1, s2|
        s1 + s2
      end

      partial_def :concat, [String, Integer] do |s1,n|
        s1 * n
      end

      partial_def :concat, [Array] do |a|
        a.join
      end

      partial_def :concat, [Object, Object] do |o1, o2|
        "Objetos concatenados"
      end
    end
  end

  it 'funcionan los multimetodos' do
    expect(A.new.concat('hello', ' world')).to eq('helloworld')
    expect(A.new.concat('hello', 3)).to eq('hellohellohello')
    expect(A.new.concat(['hello', ' world', '!'])).to eq('hello world!')
  end

  it 'multimethod lanza error si no matchea' do
    expect {A.new.concat('hello', 'world', '!')}.to raise_error(ArgumentError)
  end

  it 'mensaje multimethods' do
    expect(A.multimethods()).to eq([:concat])
  end

  it 'mensaje multimethod' do
    A.multimethod(:concat)
  end

  it 'elige bien segun distancia' do
    expect(A.new.concat("Hello", 2)).to eq("HelloHello")
    expect(A.new.concat(Object.new, 3)).to eq("Objetos concatenados")
  end
end