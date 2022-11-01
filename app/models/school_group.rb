class SchoolGroup < Organisation
  has_many :school_group_memberships
  has_many :schools, through: :school_group_memberships

  def key_stages
    schools.map(&:key_stages).flatten.uniq.compact
  end
end
