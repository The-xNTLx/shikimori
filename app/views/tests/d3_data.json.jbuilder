json.nodes(@entries.map { |entry|
  {
    date: (entry.aired_on || Time.zone.now).to_time.to_i,
    name: localized_name(entry),
    image_url: cdn_image(entry, :x96),
    group: 1
  }
})

json.links(@links.map { |link|
  {
    source: @entries.index {|v| v.id == link.source_id },
    target: @entries.index {|v| v.id == link.anime_id },
    weight: @links.count {|v| v.source_id == link.source_id }
  }
})
