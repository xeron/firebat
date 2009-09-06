module FireBat
  class User < ActiveRecord::Base
    has_and_belongs_to_many :roles
    def allowed?(role)
      authorised and roles.find_by_name(role)
    end
  end

  class Role < ActiveRecord::Base
    has_and_belongs_to_many :users
  end

  class RolesUser < ActiveRecord::Base
  end
end