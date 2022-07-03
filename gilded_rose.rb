class ItemInformation
  MINIMUM_QUALITY = 0
  MAXIMUM_QUALITY = 50

  LEGENDARY_ITEMS = [
    'Sulfuras, Hand of Ragnaros'
  ].freeze

  AGES_LIKE_WINE = [
    'Aged Brie'
  ].freeze

  QUALITY_INCREASES_THEN_DROPS = [
    'Backstage passes to a TAFKAL80ETC concert'
  ].freeze

  attr_reader :item

  def initialize(item)
    @item = item
  end

  def update_quality_and_sell_in!
    item.quality = aging_schema.next_quality
    item.sell_in = aging_schema.next_sell_in
  end

  def conjured?
    item.name.match?(/^conjured/i)
  end

  def legendary?
    LEGENDARY_ITEMS.include?(item.name)
  end

  def quality_increases_with_time?
    AGES_LIKE_WINE.include?(item.name)
  end

  def quality_increases_then_drops?
    QUALITY_INCREASES_THEN_DROPS.include?(item.name)
  end

  private

  def aging_schema
    AgingSchema.for(self).new(item)
  end
end

module AgingSchema
  REGULAR_QUALITY_CHANGE_AMOUNT = 1
  PAST_SELL_IN_QUALITY_CHANGE_AMOUNT = 2

  class << self
    def for(item_information)
      return ConjuredAgingSchema if item_information.conjured?
      return LegendaryAgingSchema if item_information.legendary?
      return ValueIncreasingWithAgeAgingSchema if item_information.quality_increases_with_time?
      return ValueIncreasesUntilSellDateAgingSchema if item_information.quality_increases_then_drops?

      DefaultAgingSchema
    end
  end

  # Common items decrease in quality in one unit until the sell in date.
  # After that, the quality decreases twice as fast.
  class DefaultAgingSchema
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def next_quality
      [item.quality - quality_change_amount, ItemInformation::MINIMUM_QUALITY].max
    end

    def next_sell_in
      item.sell_in - 1
    end

    private

    def quality_change_amount
      return AgingSchema::REGULAR_QUALITY_CHANGE_AMOUNT if item.sell_in > 0

      AgingSchema::PAST_SELL_IN_QUALITY_CHANGE_AMOUNT
    end
  end

  class ConjuredAgingSchema < DefaultAgingSchema
    private

    def quality_change_amount
      super * 2
    end
  end

  # Legendary items do not have their quality altered over time, nor do they have
  # a recommended sell in date.
  class LegendaryAgingSchema < DefaultAgingSchema
    def next_quality
      item.quality
    end

    def next_sell_in
      item.sell_in
    end
  end

  # Some items have the quality increasing over time, rather than decreasing.
  # After the sell in date, the quality increases twice as fast.
  class ValueIncreasingWithAgeAgingSchema < DefaultAgingSchema
    def next_quality
      [item.quality += quality_change_amount, ItemInformation::MAXIMUM_QUALITY].min
    end
  end

  # Some items increase in value over time, but become worthless after sell in date passes.
  class ValueIncreasesUntilSellDateAgingSchema < DefaultAgingSchema
    def next_quality
      return ItemInformation::MINIMUM_QUALITY if item.sell_in <= 0

      [item.quality += quality_increase, ItemInformation::MAXIMUM_QUALITY].min
    end

    private

    def quality_increase
      case item.sell_in
      when 1..5 then 3
      when 6..10 then 2
      else
        1
      end
    end
  end
end

def update_quality(items)
  items.each do |item|
    item = ItemInformation.new(item)
    item.update_quality_and_sell_in!
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

