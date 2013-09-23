class User < ActiveRecord::Base
  belongs_to :group
  authenticates_with_sorcery!
end
