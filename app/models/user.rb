class User
  include ActiveModel::Model
  include Paperclip
  attr_accessor :userName, :userPassword, :userEmail,
    :repeatPassword, :userAbout, :userImage
    # has_attached_file :userImage, default_url: "/images/"
    # Read more at https://www.pluralsight.com/guides/ruby-ruby-on-rails/handling-file-upload-using-ruby-on-rails-5-api#3Pjho8QSThRVif6m.99
    def initialize(data = nil)
      if data != nil
        @userName = data[:userName]
        @userPassword = data[:userPassword]
        @userEmail = data[:userEmail]
        @repeatPassword = data[:repeatPassword]
        @userAbout = data[:userAbout]
        @userImage = data[:userImage]
      end
    end

    def to_hash()
      hash = {}
      hash[:userName] = @userName
      hash[:userEmail] = @userEmail
      hash[:userAbout] = @userAbout
      hash[:userPassword] = @userPassword
      if @userImage != nil
        hash[:userAvatar] = @userImage.original_filename
      end
      hash
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
