class CacherObserver <  ActiveRecord::Observer
  observe :thr, :an

  def after_create(record)
    if record.class.name == 'Thr'
      expire_fragment_thrs_general
    elsif record.class.name == 'An'
      expire_fragment_ans(record)
    end
  end

  def after_update(record)
    if record.class.name == 'Thr'
      expire_fragment_thrs(record)
      expire_fragment_thrs_general
    elsif record.class.name == 'An'
      expire_fragment_ans(record)
    end
  end

  def after_destroy(record)
    if record.class.name == 'Thr'
      expire_fragment_thrs(record)
      expire_fragment_thrs_general
    elsif record.class.name == 'An'
      expire_fragment_ans(record)
    end
  end

private

  def expire_fragment_thrs_general
    Rails.cache.delete("views/thrs/recent_tags")
  end

  def expire_fragment_thrs(thr)
    Rails.cache.delete("views/thrs/#{thr.id}/thr_stitle")
    Rails.cache.delete("views/thrs/#{thr.id}/thr_tags")
    Rails.cache.delete("views/thrs/#{thr.id}/thr_content")
    Rails.cache.delete("views/thrs/#{thr.id}/related_thrs")
    Rails.cache.delete("views/thrs/#{thr.id}/ans_resolved_and_counter")
  end

  def expire_fragment_ans(ans)
    Rails.cache.delete("views/ans/#{ans.id}/an_content")
    Rails.cache.delete("views/thrs/#{ans.thr_id}/ans_resolved_and_counter")
  end

end
