class Feature < ActiveRecord::Base
  paginates_per 300
  has_many :quantifications
  has_many :identifications
end
