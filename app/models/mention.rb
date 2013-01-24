class Mention
  include Mongoid::Document
  include Mongoid::Geospatial
  field :topic, type: String
  field :name, type: String
  field :slug, type: String
  field :depiction, type: String
  field :start, type: DateTime
  field :finish, type: DateTime
  field :score, type: Float
  field :location, type: Point
  spatial_index :location
  belongs_to :channel, index: true
  index({topic: 1, start: 1, finish: 1})
  index(start: 1)
  index(score: 1)
  def as_json(options)
    {
      channel_name: self.channel.name,
      channel_shortname: self.channel.shortname,
      topic: self.topic,
      start: self.start,
      finish: self.finish,
      confidence: self.score,
      location: self.location,
      name: self.name
    }
  end
end
