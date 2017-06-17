def update_quality(items)
  items.map { |i| ItemContainer.new(i) }.each do |item|
    if item.name != 'Aged Brie' && item.name != 'Backstage passes to a TAFKAL80ETC concert'
      item.decrease_quality
    else
      item.increase_quality
      if item.name == 'Backstage passes to a TAFKAL80ETC concert'
        if item.sell_in < 11
          item.increase_quality
        end
        if item.sell_in < 6
          item.increase_quality
        end
      end
    end
    if item.name != 'Sulfuras, Hand of Ragnaros'
      item.sell_in -= 1
    end
    if item.sell_in < 0
      if item.name != "Aged Brie"
        if item.name != 'Backstage passes to a TAFKAL80ETC concert'
          item.decrease_quality
        else
          item.quality = 0
        end
      else
        item.increase_quality
      end
    end
  end
end

ItemContainer = Class.new(SimpleDelegator) do
  def decrease_quality
    if self.quality > 0 && !self.legendary?
      self.quality -= 1
    end
  end

  def increase_quality
    if self.quality < 50
      self.quality += 1
    end
  end

  def legendary?
    self.name == 'Sulfuras, Hand of Ragnaros'
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

