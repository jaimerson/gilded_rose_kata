class BaseQualityUpdateStrategy
  attr_reader :item

  def initialize(item)
    @item = item
  end

  def execute
    update_quality
    update_sell_in
  end

  protected

  def decrease_quality(amount=quality_update_amount)
    item.quality -= amount
    item.quality = 0 if item.quality < 0
  end

  def increase_quality(amount=quality_update_amount)
    item.quality += amount
    item.quality = 50 if item.quality > 50
  end

  def update_quality
  end

  def update_sell_in
    item.sell_in -= 1
  end

  def quality_update_amount
    item.sell_in <= 0 ? 2 : 1
  end
end

class DefaultStrategy < BaseQualityUpdateStrategy
  def update_quality
    decrease_quality
  end
end

class BackstageConcertStrategy < BaseQualityUpdateStrategy
  def update_quality
    if item.sell_in <= 0
      item.quality = 0
    else
      increase_quality(increase_amount)
    end
  end

  def increase_amount
    return 1 if item.sell_in > 10
    item.sell_in <= 5 ? 3 : 2
  end
end

class AgesWellStrategy < BaseQualityUpdateStrategy
  def update_quality
    increase_quality
  end
end

class LegendaryStrategy < BaseQualityUpdateStrategy
  def update_sell_in
  end
end

class ConjuredStrategy < BaseQualityUpdateStrategy
  def update_quality
    decrease_quality
  end

  def quality_update_amount
    super * 2
  end
end

class ItemQualityUpdater
  attr_reader :item, :strategy

  def initialize(item)
    @item = item
    @strategy = strategy_for(item)
  end

  def update!
    strategy.execute
  end

  private

  STRATEGIES = {
    'Backstage passes to a TAFKAL80ETC concert' => BackstageConcertStrategy,
    'Aged Brie' => AgesWellStrategy,
    'Sulfuras, Hand of Ragnaros' => LegendaryStrategy,
    'Conjured Mana Cake' => ConjuredStrategy
  }.freeze

  def strategy_for(item)
    STRATEGIES
      .fetch(item.name, DefaultStrategy)
      .new(item)
  end
end

def update_quality(items)
  items.each do |item|
    ItemQualityUpdater.new(item).update!
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

