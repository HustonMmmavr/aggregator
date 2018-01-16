class Film
  include ActiveModel::Model
  attr_accessor :filmTitle, :filmAbout, :filmLength, :filmYear, :filmDirector,
              :filmImage, :filmRating
  attr_accessor :userName, :userPassword, :userEmail,
    :repeatPassword, :userAbout, :userImage

    def initialize(data = nil)
      if data != nil
        @filmTitle = data[:userName]
        @filmYear = data[:filmYear]
        @filmDirector = data[:filmDirector]
        @filmAbout = data[:filmAbout]
        @filmImage = data[:filmImage]
        @filmLength = data[:filmLength]
      end
      @filmRating = 0
    end

    def to_hash()
      hash = {}
      hash[:filmTitle] = @filmTitle
      hash[:filmYear] = @filmYear
      hash[:filmDirector] @filmDirector
      hash[:filmAbout] = @filmAbout
      if @filmImage != nil
        hash[:filmImage] = @filmImage = data[:filmImage]
      end
      hash[:film]
      if @userImage != nil
        hash[:userAva] = @userImage.original_filename
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
