class Lipid < ActiveRecord::Base
  paginates_per 300
  has_many :identifications
  #belongs_to :category
end
