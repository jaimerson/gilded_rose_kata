def update_quality(items)
  items.map { |i| ItemContainer.new(i) }.each do |item|
    item.update
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
  MINIMUM_QUALITY = 0
  MAXIMUM_QUALITY = 50

  def update
    if self.ages_well? || self.ages_well_until_expired?
      self.increase_quality(amount: amount_to_increase)
    else
      self.decrease_quality
    end
    decrease_sell_in
  end

  def decrease_quality(amount: 1)
    if self.quality > MINIMUM_QUALITY && self.regular?
      self.quality -= amount
    end
  end

  def increase_quality(amount: 1)
    if self.quality < MAXIMUM_QUALITY
      self.quality += amount
    end
  end

  def amount_to_increase
    if self.ages_well_until_expired?
      if self.sell_in < 6
        return 3
      elsif self.sell_in < 11
        return 2
      end
    end
    1
  end

  def decrease_sell_in
    if self.regular?
      self.sell_in -= 1
    end
  end

  def regular?
    !self.legendary?
  end

  def legendary?
    self.name == 'Sulfuras, Hand of Ragnaros'
  end

  def ages_well?
    self.name == 'Aged Brie'
  end

  def ages_well_until_expired?
    self.name == 'Backstage passes to a TAFKAL80ETC concert'
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

