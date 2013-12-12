require 'csv'

class Castaway < Struct.new(:id, :gender, :survived)
end

class Passenger < Struct.new(:id, :gender, :survival_chance)
end

castaways = []
CSV.foreach('./data/train.csv') do |row|
  next if row[0] == "PassengerId"
  id        = row[0]
  gender    = row[4] == 'male' ? 'M' : 'F'
  survived  = row[1] == '0' ? false : true
  castaways << Castaway.new(id, gender, survived)
end

passengers = []
CSV.foreach('./data/test.csv') do |row|
  next if row[0] == "PassengerId"
  id      = row[0]
  gender  = row[3] == 'male' ? 'M' : 'F'
  passengers << Passenger.new(id, gender, 1)  
end

class GenderPredictor
  def initialize(castaways)
    male_passengers   = castaways.select {|p| p.gender == 'M' }.size
    male_survivors    = castaways.select {|p| p.survived && p.gender == 'M' }.size
    @msr  = male_survivors.to_f/male_passengers.to_f

    female_passengers = castaways.select {|p| p.gender == 'F' }.size
    female_survivors  = castaways.select {|p| p.survived && p.gender == 'F' }.size
    @fsr  = female_survivors.to_f/female_passengers.to_f    
  end

  def exec(passenger)
    survival_chance = case passenger.gender
    when 'M'
      @msr * passenger.survival_chance
    when 'F'
      @fsr * passenger.survival_chance
    end
    Passenger.new(passenger.id, passenger.gender, survival_chance)
  end
end

gender_predictor = GenderPredictor.new(castaways)

csv = passengers.map { |p| gender_predictor.exec(p) }
                .map { |p| "#{p.survival_chance > 0.7 ? 1 : 0},#{p.id}"}
                .reduce("Survived,PassengerId") { |str, line| str + "\n" + line}

File.write('data/submition.csv', csv + "\n")