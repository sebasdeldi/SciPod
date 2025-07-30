##
# CursorPaginatable module provides cursor-based pagination functionality
#
# This module implements the infinite scrolling approach described in the blog post
# "Pagy Out, Turbo In: Transforming Pagination with Infinite Scrolling and Turbo"
# by Miha Rekar, optimized for performance with large datasets.
#
module CursorPaginatable
  ##
  # Paginate a relation using cursor-based pagination
  #
  # @param [ActiveRecord::Relation] relation - The relation to paginate
  # @param [Integer] items - Number of items per page (default: 20)
  # @param [Object] before - Cursor value for the previous page (default: nil)
  # @param [Symbol] by - Field to use for cursor pagination (default: :id)
  # @param [Symbol] direction - Sort direction (default: :desc)
  # @return [Array] Tuple of [paginated_results, next_cursor]
  #
  def paginate_with_cursor(relation, items: 20, before: nil, by: :id, direction: :desc)
    # Filter by cursor start value, if one is provided. If missing, we know we're on the first page.
    if before.present?
      # Always use table-qualified column names to avoid ambiguity in joins
      table_name = relation.table_name
      if direction == :desc
        relation = relation.where("#{table_name}.#{by} < ?", before)
      else
        relation = relation.where("#{table_name}.#{by} > ?", before)
      end
    end
    
    # Order the relation by the cursor field, and limit it to `items + 1` records.
    # This is because we want to know if there are more records to load,
    # and we need to know that before we actually load them.
    relation = relation.order(by => direction).limit(items + 1).to_a
    
    # If we don't have more records, we can just return the relation as is.
    # If we do, we use the last record we're actually returning as cursor for the next page.
    if relation.size > items
      # Take only the first `items` records for this page
      page_records = relation.first(items)
      # Use the last record in this page as the cursor for next page
      cursor = page_records.last.public_send(by)
      relation = page_records
    else
      cursor = nil
    end
    
    # Return the current results and the next cursor value.
    [relation, cursor]
  end
end
