class FixedFee < ActiveRecord::Base
  NEW_CARD = 'NEW_CARD'

  def self.new_card_fee
    find_by!(code: NEW_CARD).value
  end
end
