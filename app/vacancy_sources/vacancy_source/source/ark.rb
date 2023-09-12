class VacancySource::Source::Ark
  include VacancySource::Parser

  FEED_URL = ENV.fetch("VACANCY_SOURCE_VENTRUS_FEED_URL").freeze
  SOURCE_NAME = "ark".freeze
  TRUST_UID = "4243".freeze

  # Helper class for less verbose handling of items in the feed
  class FeedItem
    def initialize(xml_node)
      @xml_node = xml_node
    end

    def [](key, namespace = nil)
      node = if namespace
               @xml_node.xpath(".//#{namespace}:#{key}")
             else
               @xml_node.xpath(".//#{key}")
             end
      node&.text&.presence
    end

    def fetch_by_attribute(element_name, attribute_name, attribute_value, namespace = nil)
      query = ".//#{namespace}:#{element_name}[@#{attribute_name}='#{attribute_value}']" if namespace
      query ||= ".//#{element_name}[@#{attribute_name}='#{attribute_value}']"
      @xml_node.xpath(query)&.text&.presence
    end

    def supp_value
      query = ".//category[@domain='School/Network']/@suppValue"
      @xml_node.xpath(query)&.first&.value&.presence
    end
  end

  include Enumerable

  def self.source_name
    SOURCE_NAME
  end

  def each
    items.each do |item|
      v = Vacancy.find_or_initialize_by(
        external_source: SOURCE_NAME,
        external_reference: item["vacancyid", "engAts"],
      )

      # An external vacancy is by definition always published
      v.status = :published
      # Consider publish_on date to be the first time we saw this vacancy come through
      # (i.e. today, unless it already has a publish on date set)
      v.publish_on ||= Date.today

      begin
        v.assign_attributes(attributes_for(item))
      rescue ArgumentError => e
        v.errors.add(:base, e)
      end

      yield v
    end
  end

  def attributes_for(item)
    {
      job_title: item["title"],
      job_advert: item["description"],
      salary: salary_range_for(item),
      expires_at: item["endDate"].presence && Time.zone.parse(item["endDate"]),
      external_advert_url: item["link"],

      job_role: job_role_for(item),
      ect_status: ect_status_for(item),
      subjects: item["subjects"].presence&.split(","),
      working_patterns: working_patterns_for(item),
      contract_type: contract_type_for(item),
      phases: phases_for(item),
    }.merge(organisation_fields(item))
    .merge(start_date_fields(item))
  end

  def salary_range_for(item)
    from = item["salaryRangeFrom", "engAts"]
    to = item["salaryRangeTo", "engAts"]

    if from.present? && to.present?
      "#{from} - #{to}"
    elsif from.present?
      "From #{from}"
    elsif to.present?
      "Up to #{to}"
    end
  end

  def start_date_fields(item)
    return {} if item["pubDate"].blank?

    parsed_date = StartDate.new(item["pubDate"])
    if parsed_date.specific?
      { starts_on: parsed_date.date, start_date_type: parsed_date.type }
    else
      { other_start_date_details: parsed_date.date, start_date_type: parsed_date.type }
    end
  end

  def job_role_for(item)
    item.fetch_by_attribute("category", "domain", "Role Type")
    .gsub(/Teacher|Cover Support Teacher|TLRs|Lead Practitioner/, "teacher")
    .gsub(/Principal|Head of School|Executive Principal|Associate Principal|Vice Principal|Assistant Principal/, "senior_leader")
    .gsub(/Head of Department|Head of Year|Head of Phase/, "middle_leader")
    .gsub(/Teaching Assistant|Cover Support Teaching Assistant/, "teaching_assistant")
    .gsub("HigherLevelteaching_assistant", "higher_level_teaching_assistant")
    .gsub(%r{SEN/Inclusion Support|Pastoral|Technician}, "education_support")
    .gsub("SEN/Inclusionteacher", "sendco")
    .gsub(/\s+/, "")
  end

  def ect_status_for(item)
    return unless item["ectSuitable"].presence

    item["ectSuitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
  end

  def working_patterns_for(item)
    item.fetch_by_attribute("category", "domain", "Working Pattern")
    .gsub("Full Time", "full_time")
    .gsub("Part Time", "part_time")
  end

  def contract_type_for(item)
    item.fetch_by_attribute("category", "domain", "Contract Type")
    .gsub("Permanent", "permanent")
    .gsub("Fixed Term", "fixed_term")
  end

  def phases_for(item)
    item.fetch_by_attribute("category", "domain", "Phase")
    .gsub("Primary", "primary")
    .gsub("Secondary", "secondary")
    &.gsub("All-through", "through")
    &.gsub(/\s+/, "")
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
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: TRUST_UID)
    urn = item.supp_value

    multi_academy_trust&.schools&.where(urn: urn).presence ||
      Organisation.where(urn: urn).presence ||
      Array(multi_academy_trust)
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL).body)
  end
end
