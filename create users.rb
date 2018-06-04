require 'Digest'

exit if  ARGV[0] == nil
exit if  ARGV[0].empty?

userName = ARGV[0].strip
pass =  Digest::SHA2.new(512).digest(ARGV[1].strip)

#Проверяем на дубль по имени пользователя
File.open('users.txt', 'r') do |f|
	while line = f.gets.strip
		if line ==  userName
			puts "User: #{userName} is already exists"
			exit
		end
	end
end

#Пишем в файл
File.open('users.txt','a') {|f| f.write "#{userName}\n"}
File.open('users.txt','a') {|f| f.write "#{pass}\n"}


 

