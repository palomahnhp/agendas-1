module EventsHelper

  def cancelable_event?(event)
    !event.canceled?
  end

  def declinable_or_aceptable_event?(event)
    !event.canceled? && !event.declined? && !event.accepted?
  end

end
