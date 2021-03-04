require "./spec_helper"
include Genetic::Crystal(Int32)

describe "Genetic::Crystal" do
  describe "roulette" do
    it "correctly selects from the population" do
      (roulette [1,2,3], [1,5,2], 30).should eq [2,2,2]*10
    end
  end
  describe "ranking" do
    it "correctly selects from the population" do
      (ranking [1,2,3], [0,5,0], 30).size.should eq 30
    end
  end
  describe "tournament" do
    it "correctly selects from the population" do
      (tournament [1,2,3], [0,5,0], 30).size.should eq 30
    end
  end
  describe "GeneticAlgorithm" do
    it "initialized" do
      fitness = ->(i : Int32) { i }
      GeneticAlgorithm.new 10, 0.8, 0.01, ->tournament(Array(T), Array(Int32), Int32), ->mutate_int32(Int32), ->cross_int32(Int32, Int32), ->init_int32, fitness
    end
    it "runs a generation" do
      fitness = ->(i : Int32) { i }
      ga = GeneticAlgorithm.new 10, 0.8, 0.01, ->tournament(Array(T), Array(Int32), Int32), ->mutate_int32(Int32), ->cross_int32(Int32, Int32), ->init_int32, fitness
      ga.generation
    end
    it "runs multiple generations" do
      fitness = ->(i : Int32) { i }
      ga = GeneticAlgorithm.new 10, 0.8, 0.01, ->tournament(Array(T), Array(Int32), Int32), ->mutate_int32(Int32), ->cross_int32(Int32, Int32), ->init_int32, fitness
      ga.generations 30
    end
    it "gets the best result" do
      fitness = ->(i : Int32) { i }
      ga = GeneticAlgorithm.new 1000, 0.5, 0.01, ->tournament(Array(T), Array(Int32), Int32), ->mutate_int32(Int32), ->cross_int32(Int32, Int32), ->init_int32, fitness
      ga.generations 10000
      ga.best.should be > 50
      puts ga.best
    end
  end
end
