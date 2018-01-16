class Film
  include ActiveModel::Model
  attr_accessor :filmTitle, :filmAbout, :filmLength, :filmYear, :filmDirector,
              :filmImage, :filmRating

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
        hash[:filmImage] = @filmImage = data[:filmImage]
      end
      hash[:film]
      if @userImage != nil
        hash[:userAva] = @userImage.original_filename
      end
      hash
    end
    @@important_params = ['filmTitle', 'filmAbout', 'filmLength', 'filmYear', 'filmDirector']

    def check (err)
      # p self.userPassword
      if @filmTitle == nil || @filmTitle == ""
        err.push("Title cant be empty")
      end

      if @filmAbout == nil || @filmAbout == ""
        err.push "About cant be empty"
      end

      if @filmLength == nil || @filmLength == ""
        err.push("Length cant be empty")
      else
        begin 
          data = @filmLength.to_i
        rescue => err
          err.push("Lenght is not an integer")
        end
      end

      if @filmYear == "" || @filmYear == nil
        err.push("Year cant be empty")
      else
        begin 
          data = @filmYera.to_i
        rescue => err
          err.push("Year is not an integer")
        end
      end

      if @filmDirector != @filmDirector
        err.push("Director cant be empty")
      end
    end
end
