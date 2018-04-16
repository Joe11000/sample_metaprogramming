#!/usr/bin/env ruby
# Doing some weird metaprogramming just to do it

require 'rspec/autorun'
require 'Benchmark'


$status_methods = 'Person::MOODS.each do |status_name|;' +
                    'define_method "#{status_name}!" do;' +
                      '"I am so #{status_name}!";' +
                    ';end;' +
                  'end'

class Person
    MOODS = %w( happy sad hopeful sleepy goofy )

    eval($status_methods)

  class << self
    def bal b
     @bal_sum ||= 0
     @bal_sum += b
    end

    @level_1 = '1 level deep'
    eval($status_methods)

    class << self
      attr_reader :level_1


      @level_2 = '2 levels deep'

      eval($status_methods)


      class << self
        attr_reader :level_2

        @level_3 = '3 levels deep'

        eval($status_methods)

        class << self
          attr_reader :level_3

          @level_4 = '4 levels deep'

          class << self
            attr_reader :level_4
          end
        end
      end
    end
  end
end



describe 'Access via instances' do
  Person::MOODS.each do |emotion|
    it 'Person  should experience each emotion' do
      expect(Person.new.send("#{emotion}!")).to eq "I am so #{emotion}!"
    end
  end
end

describe 'Access via metaclasses' do
  Person::MOODS.each do |emotion|
    it 'Person at level 1 should experience each emotion' do
      expect(Person.singleton_class.send("#{emotion}!")).to eq "I am so #{emotion}!"
    end

    it 'Person at level 2 should experience each emotion' do
      expect(Person.singleton_class.singleton_class.send("#{emotion}!")).to eq "I am so #{emotion}!"
    end
  end
end



Benchmark::bmbm(15) do |bmbm|
  bmbm.report('level 1') {Person.singleton_class.level_1}
  bmbm.report('level 2') {Person.singleton_class.singleton_class.level_2}
  bmbm.report('level 3') {Person.singleton_class.singleton_class.singleton_class.level_3}
  bmbm.report('level 4') {Person.singleton_class.singleton_class.singleton_class.singleton_class.level_4}
end

