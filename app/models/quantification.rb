class Quantification < ActiveRecord::Base
  paginates_per 300
  belongs_to :feature
  belongs_to :sample
end
