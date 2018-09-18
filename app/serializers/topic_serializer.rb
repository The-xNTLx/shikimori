class TopicSerializer < ActiveModel::Serializer
  attributes :id, :topic_title, :body, :html_body, :html_footer, :created_at,
    :comments_count, :forum, :user, :type, :linked_id, :linked_type, :linked,
    :viewed, :last_comment_viewed, :event, :episode

  def forum
    ForumSerializer.new object.topic.forum
  end

  def type
    object.topic.type
  end

  def linked_id
    object.topic.linked_id
  end

  def linked_type
    object.topic.linked_type
  end

  def user
    UserSerializer.new object.user
  end

  def linked # rubocop:disable CyclomaticComplexity, AbcSize
    return unless object.topic.linked

    case linked_type
      when Anime.name then AnimeSerializer.new object.topic.linked
      when Manga.name then MangaSerializer.new object.topic.linked
      when Character.name then CharacterSerializer.new object.topic.linked
      when Club.name then ClubSerializer.new object.topic.linked
      when Review.name then ReviewSerializer.new object.topic.linked
    end
  end

  def last_comment_viewed
    object.topic.comments.last.try(:viewed?)
  end

  def viewed
    object.viewed?
  end

  def event
    object.topic.action
  end

  def episode
    object.topic.value.to_i if object.topic.value.present?
  end
end
