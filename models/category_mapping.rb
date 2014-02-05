module CategoryMapping
  CATEGORIES_MAPPING = {
    [1, 9, 13, 14, 16, 21] => 1,
    [3, 19]                => 3,
    [2, 5, 7]              => 5,
    [8, 15]                => 15,
    [6, 11, 12, 20, 22]    => 12,
    [17, 18]               => 18,
    [4]                    => 4,
    [10]                   => 10,
    [23]                   => 23
  }

  def expand_to_old_categories(category)
    category_ids = expand_to_old_category_ids(category)
    category_ids.map { |id| Category.find(id) }
  end

  def expand_to_old_category_ids(category)
    CATEGORIES_MAPPING.key(category.id)
  end

  def map_to_new_category(category)
    old_category_ids = CATEGORIES_MAPPING.keys.select do |ids|
      ids.include?(category.id)
    end.first

    new_category_id = CATEGORIES_MAPPING[old_category_ids]
    Category.find(new_category_id)
  end
end