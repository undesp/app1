require 'Digest'

exit if  ARGV[0] == nil
exit if  ARGV[0].empty?

userName = ARGV[0].strip
pass =  Digest::SHA2.new(512).digest(ARGV[1].strip)

#Проверяем на дубль по имени пользователя
if !File.zero?("users.txt")
	File.open('users.txt', 'r') do |f|

		while line = f.gets
			if line.strip ==  userName
				puts "User: #{userName} is already exists"
				exit
			end
		end
	end
end

#Пишем в файл
File.open('users.txt','a') {|f| f.write "#{userName}\n"}
#File.open('users.txt','a:ASCII-8BIT') {|f| f.write "#{pass}\n"}
File.open('users.txt','a') {|f| f.write "#{pass}\n"}


 

