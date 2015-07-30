class Sample < ActiveRecord::Base
   has_many :quantifications

  def self.to_hash
    return Hash[*self.all.map{|sample| [sample.id, sample.short]}.flatten(1)]
  end
end
