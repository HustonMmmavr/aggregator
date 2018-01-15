class User
  include ActiveModel::Model
  attr_accessor :userName, :userPassword, :userEmail,
    :repeatPassword, :userAbout, :userImage

    def check ()
      true
    end
end
