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
    @bar = "nothing"
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
  @bar = "hi"
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
    @bar = "nothing"
  end

  def zas
    "traz"
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







