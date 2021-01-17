module Serialisers
  class School < Blueprinter::Base
    identifier(:urn)

    fields(
      :name, :local_authority, :establishment_type, :establishment_type_group,
      :open, :opened_on, :closed_on, :censused_on, :pupils, :boys, :girls,
      :gender, :ofsted_rating, :phase, :start_age, :finish_age, :capacity,
      :rural_urban_classification, :email_address, :latitude, :longitude
    )

    field(:free_school_meals_percentage) do |s, _o|
      s[:free_school_meals_percentage].to_f
    end
  end
end
