require 'httparty'

class ArkVacancySource
  include HTTParty
  include Enumerable

  base_uri 'https://arkcareers.engageats.co.uk'

  # FEED_URL = ENV.fetch("VACANCY_SOURCE_ARK_FEED_URL").freeze
  # UNITED_LEARNING_TRUST_UID = "5143".freeze
  SOURCE_NAME = "ark".freeze

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end


  def feed
    @feed ||= Nokogiri::XML(vacancies)
  end

  def vacancies
    self.class.get('/customvacanciesfeed.ashx')
  end

  # Helper class for less verbose handling of items in the feed
  class FeedItem
    def initialize(xml_node)
      @xml_node = xml_node
      @data = parse_node(xml_node)
    end

    def [](key)
      @data[key]
    end

    def parse_node(node)
      fields = {}

      node.element_children.each do |child|
        field_name = child.name
        field_value = child.text.strip

        # Handle category fields with attributes
        if field_name == 'category' && child.attributes['domain']
          field_name = child.attributes['domain'].value.downcase.parameterize.underscore
        end

        fields[field_name] = field_value
      end

      fields
    end
  end

  def self.source_name
    SOURCE_NAME
  end

  def each
    items.each do |item|
      v = Vacancy.find_or_initialize_by(
        external_source: SOURCE_NAME,
        external_reference: item["VacancyID"],
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

  private

  def attributes_for(item)
    {
      # Base data
      job_title: item["Vacancy_title"],
      job_advert: item["Advert_text"],
      salary: item["Salary"],
      expires_at: Time.zone.parse(item["Expiry_date"]),
      external_advert_url: item["link", root: true],

      # New structured fields
      job_role: item["Job_roles"].presence&.gsub("leadership", "senior_leader")&.gsub(/\s+/, ""),
      ect_status: ect_status_for(item),
      subjects: item["Subjects"].presence&.split(","),
      working_patterns: item["Working_patterns"].presence&.split(","),
      contract_type: item["Contract_type"].presence,
      # TODO: This is coming through unexpectedly in the feed - the parameterize call can be removed
      #       when the correct values are coming through
      phases: [organisations_for(item).first&.readable_phase],
      organisations: organisations_for(item),
      about_school: organisations_for(item).first&.description,
    }
  end

  def ect_status_for(item)
    return unless item["ect_suitable"].presence

    item["ect_suitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
  end

  def organisations_for(item)
    # TODO: What about central office/multiple school vacancies?
    [school_group.schools.find_by(urn: item["URN"])]
  end

  def school_group
    @school_group ||= SchoolGroup.find_by(uid: UNITED_LEARNING_TRUST_UID)
  end
end
