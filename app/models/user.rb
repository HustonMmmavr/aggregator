class User
  include ActiveModel::Model
  attr_accessor :userName, :userPassword, :userEmail,
    :repeatPassword, :userAbout, :userImage

    def initialize()

    end
    def initialize(data) 
      @userName = data[:userName]
      @userPassword = data[:userPassword]
      @userEmail = data[:userEmail]
      @repeatPassword = data[:repeatPassword]
      @userAbout = data[:userAbout]
      @userImage = data[:userImage]
    end

    def check ()
      true
    end
end
