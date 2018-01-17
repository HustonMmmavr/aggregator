class Film
  include ActiveModel::Model
  attr_accessor :filmTitle, :filmAbout, :filmLength, :filmYear, :filmDirector,
              :filmImage, :filmRating
  attr_accessor :userName, :userPassword, :userEmail,
    :repeatPassword, :userAbout, :userImage

    def initialize(data = nil)
      if data != nil
        @filmTitle = data[:filmTitle]
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
      hash[:filmDirector] = @filmDirector
      hash[:filmAbout] = @filmAbout
      if @filmImage != nil
        hash[:filmImage] = "films/" + @filmImage.original_filename
      end
      hash[:filmLength] = @filmLength
      hash
    end

    def check ()
      err = Array.new
      if @filmTitle == nil || @filmTitle == ""
        err.push("Title cant be empty")
      end

      if @filmDirector == nil || @filmDirector == ""
        err.push "Name cant be empty"
      end

      if @filmAbout == nil || @filmAbout == ""
        err.push("Email cant be empty")
      end

      if @filmLength == nil
        err.push("Length cant be empty")
      else
        begin
          data = Integer(@filmLength)
        rescue => e
          err.push("Length is not valid (not an integer)")
        end
      end


      if @filmYear == nil
        err.push("Year cant be empty")
      else
        begin
          data = Integer(@filmYear)
        rescue => e
          err.push("Year is not valid (not an integer)")
        end
      end

      err
    end
end
