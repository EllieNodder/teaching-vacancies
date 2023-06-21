class Search::VacancySort < RecordSort
  def initialize(keyword:)
    @keyword = keyword
    super
  end

  def options
    [publish_on_desc_option]
  end

  private

  attr_reader :keyword

  def publish_on_desc_option
    SortOption.new("publish_on", I18n.t("jobs.sort_by.publish_on.descending"), "desc")
  end
end
