class VideoExtractor::CoubExtractor < VideoExtractor::OpenGraphExtractor
  PARAMS_REGEXP = /(?:\?[\w=+%&]+)?/
  # Video.hosting should include these hostings
  # shiki_video should include these hostings too
  URL_REGEX = %r{
    https?://(?:www\.)?(
      (?<hosting>coub).com/view/[\wА-я_-]+#{PARAMS_REGEXP.source}
    )
  }xi

  def url
    @fixed_url ||= "https:#{Url.new(super).without_protocol}"
  end
end
