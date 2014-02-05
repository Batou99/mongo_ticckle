class Type < StaticCollection
  attribute :title, :string
  item :questions, :title => "Questions", :id => 1
  item :ideas, :title => "Ideas", :id => 2
  item :opinions, :title => "Opinions", :id => 3
end