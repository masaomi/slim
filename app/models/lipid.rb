class Lipid < ActiveRecord::Base
  paginates_per 300
  has_many :identifications
  #belongs_to :category

  def children
    self.class.where(parent: self.parent).where.not(id: self.id)
  end
end
