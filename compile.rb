puts "Enter the main file :"
path = gets.chomp

begin
	file = File.open(path)
	file.each_line do |line|
		next if not line.include?("require")

		stuff = 
rescue
	raise "Unnable to load file!"
end