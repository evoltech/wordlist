require 'wordlist/unique_filter'
require 'wordlist/mutator'

module Wordlist
  class List

    include Enumerable

    # Maximum length of words
    attr_accessor :max_length

    # Minimum length of words
    attr_accessor :min_length

    #
    # Creates a new List object with the given _options_. If a _block_
    # is given, it will be passed the newly created List object.
    #
    # _options_ may include the following keys:
    # <tt>:max_length</tt>:: The maximum length of words produced by the
    #                        list.
    # <tt>:min_length</tt>:: The minimum length of words produced by the
    #                        list.
    #
    def initialize(options={},&block)
      @mutators = []

      @max_length = nil
      @min_length = 0

      if options[:max_length]
        @max_length = options[:max_length]
      end

      if options[:min_length]
        @min_length = options[:min_length]
      end

      block.call(self) if block
    end

    #
    # Adds a mutation rule for the specified _pattern_, to be replaced
    # using the specified _substitute_. If a _block_ is given, and the
    # _substitute_ data omitted, then the _block_ will be used to
    # replace data matched by the _pattern_.
    #
    #   list.mutate 'o', '0'
    #
    #   list.mutate '0', 0x41
    #
    #   list.mutate(/[oO]/) do |match|
    #     match.swapcase
    #   end
    #
    def mutate(pattern,substitute=nil,&block)
      @mutators << Mutator.new(pattern,substitute,&block)
    end

    #
    # Enumerate through every word in the list, passing each word to
    # the given block. By default this method passes nothing to the given
    # _block_.
    #
    #   list.each_word do |word|
    #     puts word
    #   end
    #
    def each_word(&block)
    end

    #
    # Enumerates through every unique word in the list, passing each
    # unique word to the given block.
    #
    #   list.each_unique do |word|
    #     puts word
    #   end
    #
    def each_unique
      unique_filter = UniqueFilter.new()

      each_word do |word|
        if unique_filter.saw!(word)
          yield word
        end
      end

      unique_filter = nil
    end

    #
    # Enumerates through every unique mutation, of every unique word, using
    # the mutator rules define for the list. Every possible unique mutation
    # will be passed to the given _block_.
    #
    #   list.each_mutation do |word|
    #     puts word
    #   end
    #
    def each_mutation(&block)
      mutation_filter = UniqueFilter.new()

      mutator_stack = [lambda { |mutated_word|
        # skip words shorter than the minimum length
        next if mutated_word.length < @min_length

        # truncate words longer than the maximum length
        mutated_word = mutated_word[0,@max_length] if @max_length

        if mutation_filter.saw!(mutated_word)
          yield mutated_word
        end
      }]

      (@mutators.length-1).downto(0) do |index|
        mutator_stack.unshift(lambda { |word|
          prev_mutator = @mutators[index]
          next_mutator = mutator_stack[index+1]

          prev_mutator.each(word,&next_mutator)
        })
      end

      each_unique(&(mutator_stack.first))
    end

    alias each each_mutation

  end
end
