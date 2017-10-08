require "json"
require "./trainer"

classifier = Trainer.new([:books, :movies, :tv_series])
classifier.train(:books, "./data/books.json")
classifier.train(:movies, "./data/movies.json")
classifier.train(:tv_series, "./data/tv.json")
classifier.finish
data = classifier.export_data

File.open("classifier.cr", "w") do |file|
  file.puts("require \"./helpers\"\n\n")
  file.puts("class Classifier\n")
  file.puts("  include Helpers\n\n")
  data.each do |key, value|
    file.puts("  def #{key}\n")
    file.puts("    @#{key} ||= #{value}")
    file.puts("  end\n\n")
  end
  file.puts("end\n\n")

  file.puts("classifier = Classifier.new")
  file.puts("puts classifier.classify(ARGV.join(\" \"))")
end
