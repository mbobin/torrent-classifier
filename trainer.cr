require "json"
require "./helpers"

class Trainer
  include Helpers

  def initialize(@categories : Array(Symbol))
    @dictionaries = {} of Symbol => Hash(String, Int32)
    @counts = {} of Symbol => Int32
    @unique_words = 0
    @docs_count = {} of Symbol => Int32
    @per_cat_prob = {} of Symbol => Float64
    @total_docs_count = 0
  end

  def train(category, data : JSON::Any)
    memo = {} of String => Int32
    words = data
      .flat_map { |doc| process_document doc }
      .reject { |w| w.empty? }
      .group_by { |w| w }
      .reduce(memo) { |acc, (w, ws)| acc[w] = ws.size; acc }

    @dictionaries[category] = words
    @counts[category] = words.reduce(0) { |acc, (word, count)| acc + count }
    @unique_words = @dictionaries.flat_map { |cat, words| words.keys }.to_set.size
    @docs_count[category] = data.size
    @total_docs_count = @docs_count.reduce(0) { |acc, (cat, count)| acc + count }
  end

  def train(category, path : String)
    train(category, JSON.parse(File.read(path)))
  end

  def finish
    @categories.each do |cat|
      @per_cat_prob[cat] = @docs_count[cat].fdiv @total_docs_count
    end
  end

  def export_data
    {
      categories:           @categories,
      dictionaries:         @dictionaries,
      counts:               @counts,
      unique_words:         @unique_words,
      category_probability: @per_cat_prob,
    }
  end

  def categories
    @categories
  end

  def dictionaries
    @dictionaries
  end

  def counts
    @counts
  end

  def unique_words
    @unique_words
  end

  def category_probability
    @per_cat_prob
  end
end
