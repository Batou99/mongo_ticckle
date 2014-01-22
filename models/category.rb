class Category < StaticCollection
  attribute :title, :string
  item :politics      , :title => "Politics"      , :id => 1
  item :media         , :title => "Media"         , :id => 2
  item :entertainment , :title => "Entertainment" , :id => 7
  item :taboo         , :title => "Taboo"         , :id => 6
  item :tech          , :title => "Tech"          , :id => 8
  item :health        , :title => "Health"        , :id => 9
  item :green         , :title => "Green"         , :id => 10
  item :arts          , :title => "Arts"          , :id => 5
  item :ethics        , :title => "Ethics"        , :id => 3
  item :sport         , :title => "Sport"         , :id => 11
  item :obscure       , :title => "Obscure"       , :id => 12
  item :money         , :title => "Money"         , :id => 13
  item :world         , :title => "World"         , :id => 14
  item :religion      , :title => "Religion"      , :id => 4
  item :science       , :title => "Science"       , :id => 15
  item :education     , :title => "Education"     , :id => 16
  item :relationships , :title => "Relationships" , :id => 17
  item :psychology    , :title => "Psychology"    , :id => 18
  item :philosophy    , :title => "Philosophy"    , :id => 19
  item :humour        , :title => "Humour"        , :id => 20
  item :feminism      , :title => "Feminism"      , :id => 21
  item :spoken_word   , :title => "Spoken word"   , :id => 22
end
