class OfflineRecord < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :group_id, :round_id
end