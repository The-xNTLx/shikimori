class ClubPage < ActiveRecord::Base
  acts_as_list scope: [:club_id, :parent_page_id]

  belongs_to :club, touch: true
  belongs_to :parent_page, class_name: ClubPage.name
  has_many :child_pages, -> { ordered },
    class_name: ClubPage.name,
    foreign_key: :parent_page_id,
    dependent: :destroy

  enumerize :layout,
    in: Types::ClubPage::Layout.values,
    predicates: { prefix: true },
    default: Types::ClubPage::Layout[:content]

  validates :club, :name, presence: true

  scope :ordered, -> { order :position, :id }

  def to_param
    "#{id}-#{name.permalinked}"
  end

  def parents
    parent_page ? parent_page.parents + [parent_page] : []
  end

  def siblings
    parent_page ? parent_page.child_pages : club.root_pages
  end
end