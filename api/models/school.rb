module Models
  class School < Sequel::Model
    set_primary_key([:urn])
  end

  class OpenSchool < School; end
end
