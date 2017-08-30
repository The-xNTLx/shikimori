class Votable::Vote
  method_object %i[votable vote voter]

  CLEANUP_VOTE_SQL = <<-SQL
    (
      votable_type = '#{Poll.name}' and
      votable_id = :poll_id
    ) or (
      votable_type = '#{PollVariant.name}' and
      votable_id in (:poll_variant_ids)
    )
  SQL

  def call
    return unless can_vote? @votable
    cleanup_votes poll(@votable) if poll?(@votable)

    @votable.vote_by voter: @voter, vote: @vote
  end

private

  def poll? votable
    votable.is_a?(Poll) || votable.is_a?(PollVariant)
  end

  def poll votable
    votable.is_a?(Poll) ? votable : votable.poll
  end

  def cleanup_votes poll
    ActsAsVotable::Vote
      .where(voter: @voter)
      .where(
        CLEANUP_VOTE_SQL,
        poll_id: poll.id,
        poll_variant_ids: poll.variants.pluck(:id)
      )
      .destroy_all
  end

  def can_vote? votable
    !poll?(votable) || poll(votable).started?
  end
end