SULFURAS = 'Sulfuras, Hand of Ragnaros'
BACKSTAGE = 'Backstage passes to a TAFKAL80ETC concert'
AGED_BRIE = 'Aged Brie'

class ItemDecorator < SimpleDelegator
  def self.decorate_collection(items)
    items.map { |i| new(i) }
  end

  def legendary?
    name == SULFURAS
  end

  def common?
    !legendary?
  end

  def backstage?
    name == BACKSTAGE
  end

  def ages_like_wine?
    name == AGED_BRIE
  end
end

def update_quality(items)
  ItemDecorator.decorate_collection(items).each do |item|
    if !item.ages_like_wine? && !item.backstage?
      if item.quality > 0
      end
    else
      if item.quality < 50
        item.quality += 1
        if item.backstage?
          if item.sell_in < 11
            if item.quality < 50
              item.quality += 1
            end
          end
          if item.sell_in < 6
            if item.quality < 50
              item.quality += 1
            end
          end
        end
      end
    end
    if item.common?
      item.sell_in -= 1
    end
    if item.sell_in < 0
      if !item.ages_like_wine?
        if !item.backstage?
          if item.quality > 0
            if item.common?
              item.quality -= 1
            end
          end
        else
          item.quality = item.quality - item.quality
        end
      else
        if item.quality < 50
          item.quality += 1
        end
      end
    end
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

