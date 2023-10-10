class VacancySource::Source::Itrent
  class EveryImportError < StandardError; end

  include HTTParty
  include Enumerable
  include VacancySource::Parser

  SOURCE_NAME = "itrent".freeze
  ERROR_MESSAGE = "Something went wrong with iTrent Import. Response:".freeze
  FEED_URL = ENV.fetch("VACANCY_SOURCE_ITRENT_FEED_URL").freeze
  UDF_URL = ENV.fetch("VACANCY_SOURCE_ITRENT_UDF_URL").freeze

  FEED_HEADERS = {
    "Connection" => "keep-alive",
    "iTrent-Operation" => "requisition",
    "PartyName" => "MHR",
    "content-type" => "application/json",
  }.freeze

  UDF_HEADERS = {
    "Connection" => "keep-alive",
    "iTrent-Operation" => "get_udfs",
    "iTrent-Object-Type" => "REQUISITION",
    "content-type" => "application/json",
    "iTrent-UDF-ORG" => "MHR",
    "iTrent-UDF-Category" => "TeachVacs",
  }.freeze

  AUTH = {
    username: ENV.fetch("VACANCY_SOURCE_ITRENT_AUTH_USER"),
    password: ENV.fetch("VACANCY_SOURCE_ITRENT_AUTH_PASSWORD"),
  }.freeze

  def self.source_name
    SOURCE_NAME
  end

  def each
    results.each do |result|
      udfs = user_defined_fields(result["requisitionreference"])
      result["udfs"] = udfs

      v = Vacancy.find_or_initialize_by(
        external_source: SOURCE_NAME,
        external_reference: result["requisitionreference"],
      )

      # An external vacancy is by definition always published
      v.status = :published

      begin
        v.assign_attributes(attributes_for(result))
      rescue ArgumentError => e
        v.errors.add(:base, e)
      end

      yield v
    end
  end

  private

  def attributes_for(item)
    {
      job_title: item["requisitionname"],
      job_advert: item.dig("vacancyptysrchs", "vacancyptysrch", "jobdescription"),
      salary: item.dig("vacancyptysrchs", "vacancyptysrch", "formattedsalarydescription"),
      expires_at: Time.zone.parse(item["applicationclosingdate"]),
      external_advert_url: item.dig("vacancyptysrchs", "vacancyptysrch", "urllinks", "urllink", "link"),
      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      subjects: item.dig("udfs", "subjects").presence&.split("\n"),
      working_patterns: item.dig("vacancyptysrchs", "vacancyptysrch", "basis").presence&.parameterize(separator: "_"),
      contract_type: item.dig("udfs", "contracttype").presence&.parameterize(separator: "_"),
      phases: phases_for(item),
      key_stages: item.dig("udfs", "keystages").presence&.split(","),
      visa_sponsorship_available: false,
      publish_on: publish_on_for(item),
    }.merge(organisation_fields(item))
     .merge(start_date_fields(item))
     .merge(benefit_fields(item))
  end

  # Consider publish_on date to be the first time we saw this vacancy come through
  # (i.e. today, unless it already has a publish on date set)
  def publish_on_for(item)
    publish_on = item.dig("udfs", "publishon")
    if publish_on.present?
      Date.parse(publish_on)
    else
      Date.today
    end
  end

  def start_date_fields(item)
    return {} if item["startdate"].blank?

    parsed_date = StartDate.new(item["startdate"])
    if parsed_date.specific?
      { starts_on: parsed_date.date, start_date_type: parsed_date.type }
    else
      { other_start_date_details: parsed_date.date, start_date_type: parsed_date.type }
    end
  end

  def organisation_fields(item)
    schools = find_schools(item)
    first_school = schools.first

    {
      organisations: schools,
      readable_job_location: first_school&.name,
      about_school: first_school&.description,
    }
  end

  def find_schools(item)
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: item.dig("udfs", "trustuid"))
    school_urns = item.dig("udfs", "schoolurns")&.split(",")

    multi_academy_trust&.schools&.where(urn: school_urns)&.order(:created_at).presence ||
      Organisation.where(urn: school_urns)&.order(:created_at).presence ||
      Array(multi_academy_trust)
  end

  def benefit_fields(item)
    return {} if item.dig("udfs", "additionalallowances").blank?

    {
      benefits: true,
      benefits_details: item.dig("udfs", "additionalallowances"),
    }
  end

  def job_roles_for(item)
    role = item.dig("udfs", "jobrole")&.strip
    return [] if role.blank?

    Array.wrap(role.parameterize(separator: "_")
                   .gsub(/head_of_year_or_phase|head_of_year/, "head_of_year_or_phase")
                   .gsub("learning_support", "education_support")
                   .gsub(/\s+/, ""))
  end

  def ect_status_for(item)
    return unless item.dig("udfs", "ectsuitable").present?

    item.dig("udfs", "ectsuitable").to_s == "true" ? "ect_suitable" : "ect_unsuitable"
  end

  def phases_for(item)
    item.dig("udfs", "phase").strip
                             .parameterize(separator: "_")
                             .gsub("through_school", "through")
                             .gsub(/16-19|16_19/, "sixth_form_or_college")
  end

  def results
    feed.dig("RequisitionData", "requisition")
  end

  def feed
    response = HTTParty.get(FEED_URL, headers: FEED_HEADERS, basic_auth: AUTH)
    raise HTTParty::ResponseError, ERROR_MESSAGE unless response.success?

    parsed_response = JSON.parse(response.body)
    raise EveryImportError, ERROR_MESSAGE + parsed_response["error"] if parsed_response["error"]

    parsed_response
  end

  def user_defined_fields(vacancy_ref)
    headers = UDF_HEADERS.merge("iTrent-Object-Ref" => vacancy_ref)
    response = HTTParty.get(UDF_URL, headers:, basic_auth: AUTH)
    raise HTTParty::ResponseError, ERROR_MESSAGE unless response.success?

    JSON.parse(response.body)&.dig("itrent", "udfs")&.first
  end
end
