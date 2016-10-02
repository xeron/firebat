module FireBat
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  ActiveRecord::Base.establish_connection($config['database'])

  class Channel < ActiveRecord::Base
  end

  class Host < ActiveRecord::Base
  end

  class Ident < ActiveRecord::Base
  end
end
