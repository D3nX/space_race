file = File.open("main.rb", "r")

output = ""

file.each_line do |line|
  if line.include?("require_relative ")
    file_to_load = line.sub("require_relative ", "").gsub("\"", "").sub("\n", "")+".rb"
    File.open(file_to_load, "r") do |f|
      f.each_line { |ln| output += ln }
    end
    output += "\n"
  else
    output += line
  end
end

File.open("output.rb", "w") do |f|
  f.write(output)
end