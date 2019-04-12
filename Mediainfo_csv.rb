#!/usr/bin/env ruby
require 'open3'

def CheckSizemp4(input)
  targetdir = File.dirname(input)
  targetmp4 = Dir["#{targetdir}/**/*.mp4"][0]
  if ! targetmp4.nil?
    @mp4_sizemb = (File.size(targetmp4).to_f / 1000.0**2).round(2).to_s
  else
    @mp4_sizemb = "NA"
  end
end

def CheckSizemkv(input)
  @file_sizegb = '%.2f' % (File.size(input).to_f / 1000.0**3)
end

def CheckLength(input)
  stdout, stderr, status = Open3.capture3("ffprobe '#{input}'")
  ffprobeoutput = stderr.split("\n")
  ffprobeoutput.each do |line|
    if line.include?('Duration')
      @input_length = line.split(" ")[1].chomp(',')
    end
  end
end

fileinputs = []
LegalExtensions = ['mov', 'mkv','dv']
$input = ARGV[0]
if File.directory?($input)
  targets = []
  LegalExtensions.each { |extension| targets << Dir["#{$input}/**/*.#{extension}"] }
  targets.flatten.each do |file|
    fileinputs << file
  end
else
  puts "Please use a directory for input"
  exit
end

$write_to_csv = []
puts fileinputs

fileinputs.each do |fileinput|
  CheckSizemkv(fileinput)
  CheckSizemp4(fileinput)
  CheckLength(fileinput)
  @csvline = File.basename(fileinput , ".*") + ',' + @file_sizegb + ',' + @mp4_sizemb + "," + @input_length
  $write_to_csv << @csvline
end

File.open(File.expand_path("~/Desktop/MediaInfo_CSV_#{Time.now.strftime('%Y-%m-%d')}.csv"), 'w') do |f|
  f.puts "Name,Master File(gB),MP4(mb),DURATION"
   $write_to_csv.each do |line|
     f.puts(line)
   end
end
