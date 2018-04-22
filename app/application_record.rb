require 'active_record'
# it understands an in-memory ActiveRecord
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
