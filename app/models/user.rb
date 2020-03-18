class User < ActiveRecord::Base
    validates :username, presence: true, uniqueness: {case_insensitive: true}, length: { minimum: 4, maximum: 15 }
end