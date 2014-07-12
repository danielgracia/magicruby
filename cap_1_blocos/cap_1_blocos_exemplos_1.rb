# Exemplo mínimo
[1,2,3,4,5].each do |num|
    puts(num ** 2)
end

# Esta função executa um bloco, passando como argumento uma string simples
def world
  yield "World"
end

world do |str|
  puts "Hello #{str}!"
end

# Se um bloco for passado, esta funcão passa a string "Dolly" como argumento
# Do contrário, ela só retorna "Dolly"
def dolly
  if block_given?
    yield "Dolly"
  else
    "Dolly"
  end
end
  
puts dolly

dolly do |str|
  puts "Hello #{str}!"
end

# Equivalente ao visto acima, utilizando chaves
world { |str| puts "Hello #{str}!" }

# O método dolly está disponível dentro desse bloco
world do |str|
  puts "Hello #{dolly}#{str}!"
end

# Assim como a váriavel local something
something = "sucks!"
dolly do |str|
  something = dolly + " " + something
end
puts something

# Mas váriaveis locais dentro do bloco não são expostas
world do |str|
  nothing = str
end

if defined?(nothing)
  puts nothing
else
  puts "Nothing here..."
end

# Um exemplo de blocos utilizando classes para firmar
class Foo
  attr_reader :bar
  def initialize
    @bar = "Nothing!"
  end

  def run
    yield
  end

  def change
    run do
      @bar = 3
    end
  end
end

foo = Foo.new

# Da maneira como run foi definida, isso não vai mudar o valor da variavel
# dentro da instância foo, já que o bloco é declarado em um lugar onde 
# não há acesso a ela
foo.run do
  @bar = "Hi!"
end
puts foo.bar

# Mas nesse caso vai funcionar, pois o bloco é definido dentro do método
# da classe, que possuí acesso a váriavel de instância
foo.change
puts foo.bar

# Exemplos de procs
class MoreFoo
  attr_reader :bar
  def initialize
    @bar = "Nothing!"
  end

  def zas
    "Traz!"
  end

  def get_proc
    # O bloco passado ao construtor de Proc será armazenado em uma 
    # instäncia da classe
    Proc.new do
      @bar = zas
    end
  end

  def exec(arg)
    arg.call
  end
end


morefoo = MoreFoo.new

# Primeiro, alterando os valores de morefoo
change_morefoo = morefoo.get_proc

# Executando o proc
change_morefoo.call
puts morefoo.bar

# Agora, fornecendo um proc a morefoo
change_local = proc do # equivalente a Proc.new
  something = "Changed!"
end
morefoo.exec(change_local)
puts something

# Retornando em Procs

# Isto é permitido
def return_ok
  p = proc do
    return "Hello from a Proc!"
  end
  p.call
  return "Bye!"
end

puts return_ok

# Isto não é
def return_fail(proc)
  proc.call
  return "Bye!"
end

proc_fail = proc do
  return "Hello from a Proc!"
end

begin
  puts return_fail(proc_fail)
rescue
  puts "It failed!"
end

# Convertendo blocos para procs
def convert(&block)
  block
end

block = convert do
  puts "Block to Proc!"
end
block.call

# Convertendo Procs (e símbolos) em blocos

# Um array doido
array = ["Prometheus", "Bob", "Squirrel"]

# Um Proc que apenas imprime o que lhe for passado
print_string = proc do |str|
  puts str
end

# Esse código irá apenas imprimir as strings na tela
array.each do |str|
  puts str
end

# Esse é equivalente e fará a mesma coisa, mas passando um Proc
# utilizando a síntaxe explicada da ampulheta

array.each(&print_string)

# Utilizando símbolos combinados com procs para imprimir as strings 
# em upcase

array.map(&:upcase).each(&print_string)

# Lambdas

# Criando um lambda - converte e imprime objetos arbitrários na tela
print_object = lambda do |obj|
  puts obj.to_s
end

['a', 1, :c, /abc/].each(&print_object)

# Retornando de lambdas e procs
check_if_even_proc = proc do |x|
  return x.even?
end

check_if_even_lambda = ->(x) do # Sintaxe alternativa utilizando flechas e argumentos fora do bloco
  return x.even?
end

# Uma função de exemplo
def sum(array, predicate)
  array.select(&predicate).reduce(:+)
end

# Como visto anteriormente, Procs utilizando return irão falhar...
puts sum([1,2,3,4], check_if_even_proc) rescue puts "Crash!" 

# Mas lambdas não - return neste caso equivale apenas a finalizar o bloco retornando um valor
puts sum([1,2,3,4], check_if_even_lambda)

# Lambdas verificam os argumentos passados - exemplo utilizando Procs e lambdas
identity_lambda = ->(a, b) { puts [a, b].inspect }
identity_proc = proc { |a, b| puts [a, b].inspect }

identity_lambda.call(1, 2)
identity_proc.call(1, 2)

# Aqui a chamada do lambda ira falhar com um ArgumentError
identity_lambda.call(1, 2, 3) rescue puts "Crash!"
# Mas o Proc continua firme e forte, só ignorando o que vier depois do segundo argumento
identity_proc.call(1, 2, 3)

# Falhando novamente
identity_lambda.call(1) rescue puts "Crash again!"
# O que não foi passado é tratado como nil pelo Proc
identity_proc.call(1)