module Helpers
  def classify(doc)
    memo = {} of Symbol => Float64

    words = process_document(doc)
    result = categories.reduce(memo) do |a, cat|
      a[cat] = words.reduce(category_probability[cat]) { |acc, word| acc * (1.0 + dictionaries[cat].fetch(word, 0)) / (counts[cat] + unique_words) }
      a
    end

    result.max_by { |category, value| value }[0]
  end

  def process_document(doc)
    doc
      .to_s
      .downcase
      .gsub(/(\s|\.|-)?s(\d+)e(\d+)(\s|\.|-)?/, "\\1season \\2 episode \\3\\4")
      .split(/\s|-|\./)
  end
end
