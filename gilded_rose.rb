class ItemDecorator < SimpleDelegator
  LEGENDARY_ITEMS = [
    'Sulfuras, Hand of Ragnaros'
  ].freeze

  MORE_VALUABLE_UNTIL_EXPIRATION = [
    'Backstage passes to a TAFKAL80ETC concert'
  ].freeze

  MORE_VALUABLE_WITH_TIME = [
    'Aged Brie'
  ].freeze

  def aging_mechanism
    return :noop if legendary?
    return :twice_as_fast if conjured?
    return :increase_quality if ages_like_wine?
    return :increase_quality_until_expiration if more_valuable_until_expiration?
    :normal
  end

  def conjured?
    name =~ /^conjured/i
  end

  def expired?
    sell_in <= 0
  end

  def common?
    !legendary?
  end

  def more_valuable_until_expiration?
    MORE_VALUABLE_UNTIL_EXPIRATION.include? name
  end

  def ages_like_wine?
    MORE_VALUABLE_WITH_TIME.include? name
  end

  def legendary?
    LEGENDARY_ITEMS.include? name
  end
end

class UpdateQuality
  MAXIMUM_QUALITY = 50
  MINIMUM_QUALITY = 0

  def self.perform(item)
    new(item).perform
  end

  attr_reader :item

  def initialize(item)
    @item = item
  end

  def perform
    case item.aging_mechanism
    when :twice_as_fast
      decrease_quality_accounting_for_expiration(amount: 2)
    when :increase_quality
      handle_increasing_quality
    when :increase_quality_until_expiration
      handle_quality_increase_until_expiration
    when :normal
      decrease_quality_accounting_for_expiration
    end
  end

  private

  def handle_increasing_quality
    if item.expired?
      increase_quality amount: 2
    else
      increase_quality
    end
  end

  def decrease_quality_accounting_for_expiration(amount: 1)
    if item.expired?
      decrease_quality(amount: amount * 2)
    else
      decrease_quality(amount: amount)
    end
  end

  def handle_quality_increase_until_expiration
    if item.expired?
      item.quality = 0
    elsif item.sell_in < 6
      increase_quality amount: 3
    elsif item.sell_in < 11
      increase_quality amount: 2
    else
      increase_quality
    end
  end

  def decrease_quality(amount: 1)
    item.quality -= amount
    item.quality = [MINIMUM_QUALITY, item.quality].max
  end

  def increase_quality(amount: 1)
    item.quality += amount
    item.quality = [MAXIMUM_QUALITY, item.quality].min
  end
end

def update_quality(items)
  items.each do |item|
    item = ItemDecorator.new(item)
    UpdateQuality.perform(item)

    if item.common?
      item.sell_in -= 1
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

