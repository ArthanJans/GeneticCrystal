# TODO: Write documentation for `Genetic::Crystal`
module Genetic::Crystal(T)
  VERSION = "0.1.0"

  def roulette(population : Array(T), fitnesses : Array(Int32), amount : Int32) : Array(T)
    if population.size == 0
      return [] of T
    end
    total = fitnesses.sum
    survivors = [] of T
    while survivors.size < amount
      selector = (Random.rand total) + 1
      i = fitnesses[0]
      index = 0
      while i < selector
        index += 1
        i += fitnesses[index]
      end
      survivors << population[index]
    end
    return survivors
  end

  def ranking(population : Array(T), fitnesses : Array(Int32), amount : Int32) : Array(T)
    if population.size == 0
      return [] of T
    end
    rankings = [] of Int32
    fitnesses.each do |x|
      rank = 1
      rankings.each_with_index do |y, i|
        if fitnesses[i] > x
          rankings[i] += 1
        else
          rank += 1
        end
      end
      rankings << rank
    end
    total = rankings.sum
    survivors = [] of T
    while survivors.size < amount
      selector = (Random.rand total) + 1
      i = rankings[0]
      index = 0
      while i < selector
        index += 1
        i += rankings[index]
      end
      survivors << population[index]
    end
    return survivors
  end

  def tournament(population : Array(T), fitnesses : Array(Int32), amount : Int32) : Array(T)
    if population.size == 0
      return [] of T
    end
    survivors = [] of T
    while survivors.size < amount
      group = [] of Int32
      while group.size < 7
        group << Random.rand(fitnesses.size)
      end
      survivors << population[group.max_by { |x| fitnesses[x] }]
    end
    return survivors
  end

  def init_int32 : Int32
    return Random.rand(Int32)
  end

  def cross_int32(parent1 : Int32, parent2 : Int32) : Tuple(Int32, Int32)
    mask1 = 0
    mask2 = 0b11111111111111111111111111111111
    i = Random.rand(31) + 1
    while i > 0
      i-=1
      mask1 << 1
      mask2 << 1
      mask1 |= 1
    end
    return {(parent1 & mask1) | (parent2 & mask2), (parent2 & mask1) | (parent1 & mask2)}
  end

  def mutate_int32(x : Int32) : Int32
    mask = 1
    i = Random.rand(32)
    while i > 0
      i -= 1
      mask << 1
    end
    return x ^ mask
  end

  class GeneticAlgorithm(T)
    @fitnesses : Array(Int32)
    def initialize(
      @population_size : Int32,
      @copy_proportion : Float64,
      @mutation_chance : Float64,
      @selection_method : Proc(Array(T), Array(Int32), Int32, Array(T)),
      @mutate_function : Proc(T, T),
      @cross_function : Proc(T, T, Tuple(T, T)),
      @initialize_function : Proc(T),
      @fitness_function : Proc(T, Int32)
    )
      @population = [] of T
      while @population.size < @population_size
        @population << @initialize_function.call()
      end
      @fitnesses = @population.map { |x| @fitness_function.call(x) }
    end

    def generations(n : Int32)
      i = 0
      while i < n
        self.generation
        i += 1
      end
    end

    def generation()
      new_generation = [] of T
      num_copy = (@population_size * @copy_proportion).to_i
      num_cross = @population_size - num_copy
      if num_cross % 2 != 0
        num_cross -= 1
        num_copy += 1
      end
      copied = @selection_method.call @population, @fitnesses, num_copy
      parents = @selection_method.call @population, @fitnesses, num_cross
      parents.shuffle!
      use_next = true
      crossed = [] of T
      parents.each_cons_pair do |a, b|
        if use_next
          use_next = false
          children = @cross_function.call a, b
          crossed << children[0]
          crossed << children[1]
        else
          use_next = true
        end
      end

      new_generation = copied + crossed
      new_generation.each_with_index do |x, i|
        if Random.rand < @mutation_chance
          new_generation[i] = @mutate_function.call(x)
        end
      end

      @population = new_generation
      @fitnesses = @population.map { |x| @fitness_function.call(x) }
    end

    def best() : T
      highest = @fitnesses[0]
      best = 0
      @fitnesses.each_with_index do |x, i|
        if x > highest
          best = i
          highest = x
        end
      end
      return @population[best]
    end

  end
end
