class Feature < ActiveRecord::Base
  paginates_per 300
  has_many :quantifications
  has_many :identifications
  def quants
    quant = {}
    ActiveRecord::Base.connection.execute('SELECT sample_id, raw, norm FROM quantifications WHERE feature_id = %i'%self.id).each do |row|
      quant[row[0].to_i] = [row[1].to_f,row[2].to_f]
    end
    return quant
  end
end
