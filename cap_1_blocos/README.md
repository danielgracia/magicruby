# Blocos, Procs, Lambdas e Etc

## Blocos
Diversas tarefas em Ruby utilizam extensivamente o conceito de blocos, com o exemplo mais simples sendo iterar por elementos em arrays:

    [1,2,3,4,5].each do |num|
        puts(num ** 2)
    end

Blocos são a fundação para a maior parte das técnicas de metaprogramação existentes em Ruby, logo é util entender melhor o que eles são e como funcionam.

### Introdução a blocos
Um bloco pode ser considerado como um "pseudo-método" atrelado a invocação de um método de fato. Como métodos tradicionais, um bloco aceita argumentos, e possuí escopo restrito, isto é, váriaveis locais criadas dentro dele não podem ser acessadas fora do bloco. 

Ao contrário de métodos, porém, blocos não podem existir por si só: eles devem ser declarados como o ultimo elemento de uma invocação de método, e então podem ser invocados dentro dela utilizando o comando ***yield***.

Um exemplo simples demonstrando a sintaxe disso:
    
    # Esta função executa um bloco, passando como argumento uma string simples
    def world
        yield "World"
    end
    
    world do |str|
        puts "Hello #{str}!"
    end
    
O comando *yield* executa o bloco fornecido na invocacão da função, opcionalmente fornecendo parâmetros de execução. Se nenhum bloco for fornecido, uma erro será lançado notificando o usuário.

    world # LocalJumpError: no block given (yield)

É possível verificar dentro do método se um bloco foi passado, e customizar de acordo, utilizando o comando *block_given?*

    def dolly
        if block_given?
            "Dolly"
        else
            yield "Dolly"
        end
    end
    
    puts dolly
    dolly do |str|
        puts "Hello #{str}!"
    end
    
Blocos aceitam duas síntaxes distintas para definir o ínicio e o fim deles: utilizando *do* e *end*, ou utilizando chaves (*{* e *}*). Qual das síntaxes utilizar é uma decisão do desenvolvedor.

    world { |str| puts "Hello #{str}!" } # Equivalente ao visto acima

Nos textos, daremos preferência a síntaxe utilizando chaves para blocos curtos que caibam em uma linha, e utilizando *do* e *end* em todos os outros casos.

### Características padrão de blocos
Blocos, por padrão, possuem regras de escopo um pouco diferentes do que se possa estar acostumado comparando com outras linguagens de programação. Várias delas são intuitivas e desenvolvedores se baseiam nelas para programar mesmo sem saber, mas é útil identifica-lás. Será utilizada uma linguagem simples para explicar tais regras, mas é recomendável você ter alguma compreensão do que é o conceito de *escopo* em linguagens de programação.

A maioria das regras a seguir são simples de entender se você considerar que **um bloco deve agir como se fosse parte da função onde ele é declarado**.

- Um bloco pode acessar todas as váriaveis e métodos disponíveis ao método que o define.
- Quando é utilizado o comando *return* para retornar explicitamente em um bloco, a função onde ele está contido irá de fato retornar o valor especificado (ou seja, *return* interrompe o fluxo de execução da função onde o bloco está contido)
- Um bloco não é estrito quanto aos argumentos que recebe. Ao contrário de um método, por exemplo, se você passar mais ou menos argumentos a *yield* do que são especificados pelo bloco, não são lançados erros. Argumentos extras são ignorados, argumentos faltantes são inicializados como nil.

Os próximos exemplos serão úteis para especificar melhor o comportamento dos blocos.

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

## Procs
Uma deficiência de blocos é que eles não são equivalentes a funções em outras linguagens, como JavaScript, por exemplo, onde você pode tratar funções como objetos. Para tratar blocos como objetos é necessário utilizar **Procs**.

A classe Proc funciona como uma espécie de "container" para blocos. Instâncias de Proc possuem o método ***call***, que executa o bloco armazenado com os argumentos que forem passados. Procs preservam o contexto onde o bloco foi definido, isto é, blocos podem acessar as váriaveis do escopo onde foram defindos. Em outras palavras, Procs preservam a primeira regra definida na sessão anterior: métodos e váriaveis disponíveis ao método que definiu o bloco do Proc também ficam disponíveis ao próprio bloco.

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

      def exec(proc)
        proc.call
      end
    end


    morefoo = MoreFoo.new

    # Primeiro, alterando os valores de morefoo
    change_morefoo = morefoo.proc

    # Executando o proc
    change_morefoo.call
    puts morefoo.bar

    # Agora, fornecendo um proc a morefoo
    change_local = proc do # equivalente a Proc.new
      something = "Changed!"
    end
    morefoo.exec(change_local)
    puts something
    
Procs também preservam a segunda regra se eles estiverem sendo executados dentro do método onde foram criados. Porém, se eles forem executados fora do método que os originou e utilizarem *return*, um erro será lançado.

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

### Procs e Blocos
Em algumas situações, pode ser útil tratar blocos e Procs de forma intercambiável dentro de métodos, isto é, tratar um Proc como um bloco ou converter um bloco para um Proc. Ruby traz diversas maneiras de fazer isso.

#### Blocos como procs
Em algumas situações pode não ser necessário executar o bloco imediatamente, e sim ele ser armazenado como um Proc e chamado em algum momento posterior na execução do programa. É possível tratar esse tipo de caso de forma pratica declarando funções utilizando um parâmetro-ampulheta (*ampersand-parameter*):

Quando o ultimo parâmetro de uma função é declarado com uma ampulheta na frente do nome, esse parâmetro se torna especial e passa a representar o bloco passado a função na forma de um Proc.

    # Convertendo blocos para procs
    def convert(&block)
      block
    end

    block = convert do
      puts "Block to Proc!"
    end
    block.call

#### Procs (e outros) como blocos
Em outros casos, em particular quando estamos invocando funções que aceitam apenas blocos e não Procs, é possível colocar uma ampulheta na frente do nome do valor sendo passado para ele ser tratado como um bloco a fornecer para o método.

Em particular, a ampulheta funciona com qualquer valor, de qualquer classe, que implemente o método *to_proc*. Procs podem ser convertidos para blocos diretamente pela implementação do Ruby, e outros tipos de objetos podem ser convertidos para Procs antes da conversão.

Um exemplo de classe que implementa *to_proc* é a classe Symbol. Qualquer símbolo pode ser convertido para um Proc, e a implementação de *to_proc* utilizada é equivalente, salvo detalhes de implementação, a:

    def to_proc
      Proc.new do |obj|
        obj.send(self)
      end
    end

O método *send*, em si, é extremamente utilizado em metaprogramação, e permite executar métodos de forma arbitrária e dinâmica (mais especificamente, ele executa o primeiro método que encontrar do objeto onde ele foi invocado, com nome igual ao símbolo passado). Ele será explorado mais a frente.

Aqui são mostrados exemplos utilizando tanto Procs como símbolos.

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

### Lambdas
**Lambdas** são tipos especiais de Procs. A maneira mais simples de entender um lambda é que, enquanto um Proc normal funciona como um bloco, um lambda funciona como um método. Em outras palavras:

- Quando lambdas retornam explicitamente, eles não afetam a execução do método que os executa - eles agem da mesma maneira que um método retornaria- 
- Lambdas verificam o número de argumentos passados para execução, e permitem que você defina valores padrão para argumentos não fornecidos.

Porém, assim como Procs normais, lambdas preservam o contexto onde foram definidos em relação as váriaveis e métodos disponíveis no escopo de onde foram originados.

    # Criando um lambda - converte e imprime objetos arbitrários na tela
    print_object = lambda do |obj|
      puts obj.to_s
    end

    ['a', 1, :c, /abc/].each(&print_object)

    # Retornando de lambdas e procs
    
    # Proc de exemplo
    check_if_even_proc = proc do |x|
      return x.even?
    end
    
    # Sintaxe alternativa utilizando flechas e argumentos fora do bloco
    check_if_even_lambda = ->(x) do
      return x.even?
    end

    # Uma função de exemplo
    def sum(array, predicate)
      array.select(&predicate).reduce(:+)
    end

    # Como visto anteriormente, Procs utilizando return irão falhar...
    puts sum([1,2,3,4], check_if_even_proc) rescue puts "Crash!" 

    # Mas lambdas não - return neste caso equivale apenas a finalizar o bloco 
    # retornando um valor
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
