feature 'Event page' do

  scenario 'visit the event detail page', :search do
    event = create(:event, published_at: Time.zone.yesterday)
    Event.reindex
    Sunspot.commit
    visit visitors_path

    click_link event.title

    expect(page).to have_content event.title
  end

  scenario 'visit search by keyword and area result page', :search do
    event = create(:event, title: 'New event from Capybara', published_at: Time.zone.yesterday)
    visit visitors_path

    fill_in :keyword, with: 'Capybara'
    select event.position.area.title, from: :area

    click_button I18n.t('main.form.search')
    expect(page).to have_content event.title
  end

  scenario 'visit non results search page' do
    event = create(:event, title: 'New not found event', published_at: Time.zone.yesterday)
    visit visitors_path

    fill_in :keyword, with: 'Capybara'
    click_button I18n.t('main.form.search')

    expect(page).not_to have_content event.title
    PublicActivity.set_controller(nil)
  end

  scenario 'show only published events and status done or accepted', :search do
    event1 = create(:event, published_at: Time.zone.yesterday, title: 'event1')
    event2 = create(:event, published_at: Time.zone.yesterday, title: 'event2')
    event3 = create(:event, published_at: Time.zone.today, title: 'event3')
    event4 = create(:event, published_at: Time.zone.today, title: 'event4')
    event5 = create(:event, published_at: Time.zone.tomorrow, title: 'event5')
    event6 = create(:event, published_at: Time.zone.tomorrow, title: 'event6')

    event1.update(status: :accepted)
    event2.update(status: :requested)
    event3.update(status: :done)
    event4.update(status: :canceled)
    event5.update(status: :accepted)
    event6.update(status: :done)

    Event.reindex
    Sunspot.commit

    visit visitors_path

    expect(page).to have_content event1.title
    expect(page).not_to have_content event2.title
    expect(page).to have_content event3.title
    expect(page).not_to have_content event4.title
    expect(page).not_to have_content event5.title
    expect(page).not_to have_content event6.title
  end

  scenario 'show events on atom feed', :search do
    event1 = create(:event, published_at: Time.zone.yesterday, title: 'event1')

    event1.update(status: :accepted)

    Event.reindex
    Sunspot.commit

    visit visitors_path

    expect(page.html).to include('<link rel="alternate" type="application/atom+xml" title="ATOM" href="/visitors.atom" />')
    expect(page.html).to include('<link rel="alternate" type="application/rss+xml" title="RSS" href="/visitors.rss" />')

    page.find('#atom_link').click

    expect(page).to have_content event1.title
    expect(page).to have_content event1.description
    expect(page).to have_content event1.scheduled
    expect(page).to have_content event1.position.holder.full_name
  end

  scenario 'search lobby activity for visitors ', :search do
    event = create(:event, title: 'Test for check lobby_activity for visitors')
    event.lobby_activity = true
    event.event_agents << create(:event_agent)
    event.save!

    visit visitors_path
    check 'lobby_activity'
    click_button I18n.t('backend.search.button')

    expect(page).to have_content "Test for check lobby_activity for visitors"
  end

  scenario 'When search by holder need display his events as participant', :search do
    position = create(:position)
    event = create(:event, position: position, title: "Acting as participant")
    create(:event, position: position, title: "Not involved event")
    participant = create(:participant, event_id: event.id)
    Event.reindex
    Sunspot.commit

    visit visitors_path
    select participant.position.holder.full_name_comma, from: :holder
    click_button I18n.t('backend.search.button')
    expect(page).to have_content "Acting as participant"
    expect(page).not_to have_content "Not involved event"
  end

  scenario 'When search by holder need display his events as position', :search do
    position = create(:position)
    event1 = create(:event, position: position, title: "Acting as participant")
    participant = create(:participant, event_id: event1.id)
    create(:event, position: position, title: "Not involved event")
    Event.reindex
    Sunspot.commit

    visit visitors_path
    select participant.position.holder.full_name_comma, from: :holder
    click_button I18n.t('backend.search.button')

    expect(page).to have_content "Acting as participant"
    expect(page).not_to have_content "Not involved event"
  end

  describe "Agenda" do
    scenario 'Should redirect to visitors#index when given holder does not exist' do
      visit agenda_path(holder: 1, full_name: "unexisting-fullname")

      expect(page).to have_content I18n.t('activerecord.models.holder.not_found')
    end

    scenario 'Should show holder agenda when given holder exists', :search do
      holder = create(:holder)
      visit agenda_path(holder: holder.id, full_name: holder.full_name)

      expect(page).not_to have_content I18n.t('activerecord.models.holder.not_found')
    end
  end

  describe 'CSV export link' do

    scenario 'Should download a CSV file UTF-8 encoded', :search do
      event = create(:event, published_at: Time.zone.yesterday)
      Event.reindex
      Sunspot.commit
      visit visitors_path

      click_link "Exportar"

      header = page.response_headers['Content-Type']
      expect(header).to match 'text/csv; charset=utf-8'
    end

    scenario 'Should download CSV file containing current filtered events', :search do
      event = create(:event, published_at: Time.zone.yesterday)
      Event.reindex
      Sunspot.commit
      visit visitors_path

      click_link "Exportar"

      expect(page).to have_content event.title
      expect(page).to have_content event.description
      expect(page).to have_content event.location
      expect(page).to have_content event.position.holder.full_name
      expect(page).to have_content I18n.l(event.scheduled, format: :short)
    end

  end

  describe 'show' do

    scenario 'Display event mandatory info' do
      event = create(:event, title: 'Lobby event')

      visit show_path(event)

      expect(page).to have_content event.title
      expect(page).to have_content event.location
      expect(page).to have_content event.description
      expect(page).to have_content event.position.holder.first_name
      expect(page).to have_content event.position.title.custom_titleize
      expect(page).to have_content event.position.area.title.custom_titleize
    end

    scenario 'Display event attachments public' do
      event = create(:event, title: 'Lobby event')
      attachment_public = create(:attachment, public: true, event: event)
      attachment_old = create(:attachment, event: event)
      attachment_private = create(:attachment, public: false, event: event)
      attachment_old.update_column(:public, nil)

      visit show_path(event)

      expect(page).to have_content attachment_public.title
      expect(page).to have_content attachment_public.description
      expect(page).to have_content attachment_old.title
      expect(page).to have_content attachment_old.description
      expect(page).not_to have_content attachment_private.title
      expect(page).not_to have_content attachment_private.description
    end

    scenario 'Display event lobby info' do
      event = create(:event, title: 'Lobby event')
      event.lobby_activity = true
      event.event_agents << create(:event_agent)
      event.event_represented_entities << create(:event_represented_entity)
      event.save!

      visit show_path(event)

      expect(page).to have_content event.organization.name
      expect(page).to have_content event.event_agents.first.name
      expect(page).to have_content event.event_represented_entities.first.name
    end

    scenario 'Display event lobby agents when organization have canceled_at' do
      event = create(:event, title: 'Lobby event')
      event.lobby_activity = true
      event.event_agents << create(:event_agent)
      event.save!
      event.organization.update(canceled_at: Date.current)

      visit show_path(event)

      expect(page).to have_content event.event_agents.first.name
    end

    scenario 'Display scheduled info' do
      event = create(:event, title: 'Lobby event')

      visit show_path(event)
      expect(page).to have_content I18n.l event.scheduled, format: :complete
    end

    scenario 'Display event without sheduled info' do
      event = create(:event, title: 'Lobby event')
      event.declined_reasons = 'test'
      event.scheduled = nil
      event.save!

      visit show_path(event)

      expect(page).to have_content event.title
    end

  end

end
