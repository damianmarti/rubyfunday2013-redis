REDIS_SERVER = ENV['REDIS_SERVER'] || "localhost"
REDIS_PORT = ENV['REDIS_PORT'] || 6379
REDIS_DB = 2

%w{rubygems rdf rdf/ntriples redis}.each{|r| require r}

redis = Redis.new(:host => REDIS_SERVER, :port => REDIS_PORT, :db => REDIS_DB)

def fixed_encoding(data)
	data.object.to_s.unpack('U*').pack('C*').force_encoding("UTF-8")
end


count = 0

RDF::Reader.open("data/actor_names.nt") do |reader|
	reader.each_statement do |statement|
		#puts "Subject: #{statement.subject} - Predicate: #{statement.predicate} - Object: #{statement.object}"
		redis.set "actors:#{statement.subject}:name", fixed_encoding(statement.object)
		puts "#{count} actors loaded" if (count += 1) % 100 == 0
	end
end

puts "done actors!"


count = 0

RDF::Reader.open("data/movie_titles.nt") do |reader|
	reader.each_statement do |statement|
		#puts "Subject: #{statement.subject} - Predicate: #{statement.predicate} - Object: #{statement.object}"
		redis.set "movies:#{statement.subject}:name", fixed_encoding(statement.object)
		puts "#{count} movies loaded" if (count += 1) % 100 == 0
	end
end

puts "done movies!"


count = 0

RDF::Reader.open("data/actor_movies.nt") do |reader|
	reader.each_statement do |statement|
		if statement.predicate == "http://data.linkedmdb.org/resource/movie/actor"
			#puts "Subject: #{statement.subject} - Predicate: #{statement.predicate} - Object: #{statement.object}"
			redis.sadd "movies:#{statement.subject}:actors", statement.object
			redis.sadd "actors:#{statement.object}:movies", statement.subject
			puts "#{count} relationships loaded" if (count += 1) % 100 == 0
		end
	end
end

puts "done!"