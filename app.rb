require 'csv'
require 'awesome_print'

class Passenger < Struct.new(:id, :gender, :alive)
end

passengers = []
CSV.foreach('./data/train.csv') do |row|
  next if row[0] == "PassengerId"
  id      = row[0]
  gender  = row[4] == 'male' ? 'M' : 'F'
  alive   = row[1] == '0' ? false : true
  passengers << Passenger.new(id, gender, alive)
end

test = []
CSV.foreach('./data/test.csv') do |row|
  next if row[0] == "PassengerId"
  id      = row[0]
  gender  = row[3] == 'male' ? 'M' : 'F'
  test << Passenger.new(id, gender)  
end

male_passengers   = passengers.select {|p| p.gender == 'M' }.size
female_passengers = passengers.select {|p| p.gender == 'F' }.size

male_survivors    = passengers.select {|p| p.alive && p.gender == 'M' }.size
female_survivors  = passengers.select {|p| p.alive && p.gender == 'F' }.size

msr  = male_survivors.to_f/male_passengers.to_f
fsr  = female_survivors.to_f/female_passengers.to_f

def survived(passenger, m, f)
  if passenger.gender == 'M' && m > 0.70
    true
  elsif passenger.gender == 'F' && f > 0.70
    true
  else
    false
  end
end

result = test.map do |p|
  "#{survived(p, msr, fsr) ? 1 : 0},#{p.id}"
end

File.write('data/submition.csv', "Survived,PassengerId\n" + result.join("\n") + "\n")