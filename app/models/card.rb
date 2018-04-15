require_relative '../application_record.rb'
# it understands content that can be voted on
class Card < ApplicationRecord
  # attr_reader :body
  belongs_to :conversation

  # def initialize(body)
  #   @body = body.to_s
  # end

  def ==(other)
    body == other.body
  end

  def hash
    body.hash
  end

  def to_s
    'CARD_' + body
  end
end
