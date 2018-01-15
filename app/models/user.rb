class User
  include ActiveModel::Model
  attr_accessor :userName, :userPassword, :userEmail,
    :repeatPassword, :userAbout, :userImage
    # def initialize
    #
    # end

    def initialize(data = nil)
      # p data
      if data != nil
        @userName = data[:userName]
        @userPassword = data[:userPassword]
        @userEmail = data[:userEmail]
        @repeatPassword = data[:repeatPassword]
        @userAbout = data[:userAbout]
        @userImage = data[:userImage]
      end
    end

    def check (err)
      # p self.userPassword
      if @userPassword == nil || @userPassword == ""
        err.push("Password cant be empty")
      end

      if @userName == nil || @userName == ""
        err.push "Name cant be empty"
      end

      if @userEmail == nil || @usrEmail == ""
        err.push("Email cant be empty")
      end

      if @userPassword != @repeatPassword
        err.push("Passwords doesn't match")
      end
    end
end
