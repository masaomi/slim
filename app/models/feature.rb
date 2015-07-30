class Feature < ActiveRecord::Base
  paginates_per 300
  has_many :quantifications
  has_many :identifications
  def quants
    quant = {}
    unless self.quantifications.loaded?
      ActiveRecord::Base.connection.execute('SELECT sample_id, raw, norm FROM quantifications WHERE feature_id = %i'%self.id).each do |row|
        quant[row[0].to_i] = [row[1].to_f,row[2].to_f]
      end
    else
      self.quantifications.each do |q|
        quant[q.sample_id] = [q.raw,q.norm]
      end
    end
    return quant
  end
  def get_oxichain
    return nil unless self.oxichain?
    self.class.where(oxichain: self.oxichain).order(m_z: :asc)
  end
end
