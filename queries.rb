REDIS_SERVER = ENV['REDIS_SERVER'] || "localhost"
REDIS_PORT = ENV['REDIS_PORT'] || 6379
REDIS_DB = 2

%w{rubygems redis}.each{|r| require r}

redis = Redis.new(:host => REDIS_SERVER, :port => REDIS_PORT, :db => REDIS_DB)

#Al Pacino
al_pacino = "actors:http://data.linkedmdb.org/resource/actor/29726"
puts redis.get "#{al_pacino}:name"
#Andy García
andy_garcia = "actors:http://data.linkedmdb.org/resource/actor/31813"
puts redis.get "#{andy_garcia}:name"

puts ""

puts "Al Pacino movies"
redis.smembers("#{al_pacino}:movies").each {|movie| puts redis.get "movies:#{movie}:name"}

puts ""

puts "Andy Garcia movies"
redis.smembers("#{andy_garcia}:movies").each {|movie| puts redis.get "movies:#{movie}:name"}

puts ""

movies_al_pacino_andy_garcia = redis.sinter "#{al_pacino}:movies", "#{andy_garcia}:movies"

puts "Movies donde actuan Al Pacino y Andy Garcia juntos"
movies_al_pacino_andy_garcia.each {|movie| puts redis.get "movies:#{movie}:name"}

puts ""

#The Godfather
godfather = "movies:http://data.linkedmdb.org/resource/film/43338"
puts redis.get "#{godfather}:name"
puts "Actors:"
redis.smembers("#{godfather}:actors").each {|actor| puts redis.get "actors:#{actor}:name"}
puts ""

#The Godfather II
godfather2 = "movies:http://data.linkedmdb.org/resource/film/38370"
puts redis.get "#{godfather2}:name"
puts "Actors:"
redis.smembers("#{godfather2}:actors").each {|actor| puts redis.get "actors:#{actor}:name"}
puts ""

#The Godfather III
godfather3 = "movies:http://data.linkedmdb.org/resource/film/329"
puts redis.get "#{godfather3}:name"
puts "Actors:"
redis.smembers("#{godfather3}:actors").each {|actor| puts redis.get "actors:#{actor}:name"}
puts ""

puts "Actors Godfather III ordenados alfabeticamente"
puts redis.sort("#{godfather3}:actors", :order => "alpha", :by => "actors:*:name", :get => "actors:*:name")
puts ""

puts "Actors en las 3 Godfather"
redis.sinter("#{godfather}:actors","#{godfather2}:actors","#{godfather3}:actors").each {|actor| puts redis.get "actors:#{actor}:name"}
puts ""

puts "Actors en alguna de las 3 Godfather"
redis.sunion("#{godfather}:actors","#{godfather2}:actors","#{godfather3}:actors").each {|actor| puts redis.get "actors:#{actor}:name"}
puts ""

puts "Actors que estuvieron en la 1 y no estan en la 2"
redis.sdiff("#{godfather}:actors","#{godfather2}:actors").each {|actor| puts redis.get "actors:#{actor}:name"}