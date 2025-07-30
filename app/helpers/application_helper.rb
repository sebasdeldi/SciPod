module ApplicationHelper
  def formatted_favorites_count(count)
    return "" if count.nil? || count == 0

    number_to_human(count,
      units: {
        thousand: 'k',
        million: 'm',
        billion: 'b'
      },
      precision: 1,
      significant: false,
      strip_insignificant_zeros: true
    )
  end
end
