class AnimeOnline::BrokenVkVideosCleaner
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    videos.find_each(batch_size: 500) do |video|
      raise 'not vk' unless video.vk?

      puts "checking ##{video.id} ep #{video.episode} for #{video.anime.to_param}"
      process_broken(video) if checker.video_broken? video
      sleep 1.0/4
    end
  end

private
  def videos
    AnimeVideo
      .order(id: :desc)
      .where(state: 'working')
      .where("url like '%//vkontakte.ru%' or url like '%//vk.com%'")
      .includes(:anime, :reports)
  end

  def process_broken video
    NamedLogger.anime_video_vk.info "##{video.id} ep #{video.episode} for #{video.anime.to_param} is broken (#{video.url})"
    video.broken!
    broken_reports(video).each {|report| report.accept! report_approver }
  end

  def broken_reports video
    video.reports.select {|v| v.broken? && v.pending? }
  end

  def report_approver
    BotsService.get_poster
  end

  def checker
    @checker ||= AnimeOnline::ReportWorker.new
  end
end
