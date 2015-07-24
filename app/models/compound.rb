class Compound < ActiveRecord::Base
  #default_scope :order => 'created_at DESC'
  paginates_per 100
  belongs_to :quant
  belongs_to :lipid
end
