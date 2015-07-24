class Lipid < ActiveRecord::Base
  paginates_per 100
  has_many :compounds
  belongs_to :category
end
