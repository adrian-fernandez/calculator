# frozen_string_literal: true

class TimeMeter
  def self.call
    t1 = Time.now.to_f
    result = yield if block_given?
    t2 = Time.now.to_f

    { result:, duration: t2 - t1 }
  end
end
