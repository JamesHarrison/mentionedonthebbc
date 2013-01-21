class Channel
  include Mongoid::Document
  field :name, type: String
  field :shortname, type: String
  has_many :mentions

  # Add new mentions for this channel
  def add_new_mentions(start_time, end_time)
    topics_json = Faraday.get("http://livetopics.prototyping.bbc.co.uk/topics?from=#{start_time.iso8601}&to=#{end_time.iso8601}&service=#{self.shortname}").body
    topics = JSON.parse(topics_json)['results']
    sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
    for topic in topics
      query = %{PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX : <http://dbpedia.org/resource/>
PREFIX dbpedia2: <http://dbpedia.org/property/>
PREFIX dbpedia: <http://dbpedia.org/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX dbpediaont: <http://dbpedia.org/ontology/>
SELECT ?name ?lat ?long ?depiction
WHERE {
  { <#{topic['topic']}> geo:lat ?lat .}
  { <#{topic['topic']}> geo:long ?long .}
  { <#{topic['topic']}> rdf:type dbpediaont:Place .}
  { <#{topic['topic']}> foaf:name ?name .}
  OPTIONAL { <#{topic['topic']}> foaf:depiction ?depiction .}
}
LIMIT 1}
      puts "Looking up #{topic['topic']}"
      results = sparql.query(query)
      if results.size > 0
        data = results.first
        p data
        # we've got geospatial coords, make a mention if needed
        mention = self.mentions.where(topic: topic['topic'], start: Time.parse(topic['time']['start'])).first rescue nil
        if !mention
          mention = self.mentions.new
          mention.location = {lat: data[:lat].value, long: data[:long].value}
          mention.start = Time.parse(topic['time']['start'])
          mention.finish = Time.parse(topic['time']['end'])
          mention.score = topic['score']
          mention.topic = topic['topic']
          mention.name = data[:name].value
          mention.depiction = data[:depiction].to_s
          mention.slug = topic['topic'].gsub('http://dbpedia.org/resource/','')
          mention.channel = self
          mention.save
        end
      end
    end
  end
end

