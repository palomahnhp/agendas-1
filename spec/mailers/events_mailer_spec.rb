feature 'Events Mailer' do

  describe "Cancel Event" do
    background do
      user = create(:user, :user)
      login_as user
      clear_emails
      @event = create(:event, title: 'New event from Capybara', user: user)
      @event.update(status: 'accepted')
      @event.cancel = 'true'
      @event.canceled_reasons = 'test'
      @event.lobby_contact_email = 'test@test'
      @event.current_user = user
      @event.lobby_activity = true
      @event.save!
      open_email(@event.lobby_contact_email)
    end

    scenario 'cancel event mail ' do
      expect(current_email).to have_content I18n.t('mailers.cancel_event.text1', title: @event.title)
    end

  end

  describe "Decline Event" do

    background do
      user = create(:user, :user)
      login_as user
      clear_emails
      @event = create(:event, title: 'New event from Capybara', user: user)
      @event.lobby_contact_firstname = 'test_name'
      @event.lobby_contact_lastname = 'test_other_name'
      @event.lobby_contact_email = 'test_lobby_mail'
      @event.decline = 'true'
      @event.declined_reasons = 'test'
      @event.current_user = user
      @event.lobby_activity = true
      @event.save!
      open_email(@event.lobby_contact_email)
    end

    scenario 'decline event mail' do
      expect(current_email).to have_content I18n.t('mailers.decline_event.text1', title: @event.title)
    end

  end

  describe "Accept Event" do

    background do
      user = create(:user, :user)
      login_as user
      clear_emails
      @event = create(:event, title: 'New event from Capybara', user: user)
      @event.lobby_contact_firstname = 'test_name'
      @event.lobby_contact_lastname = 'test_other_name'
      @event.lobby_contact_email = 'test_lobby_mail'
      @event.accept = 'true'
      @event.current_user = user
      @event.lobby_activity = true
      @event.save!
      open_email(@event.lobby_contact_email)
    end

    scenario 'accept event mail' do
      expect(current_email).to have_content I18n.t('mailers.accept_event.text1', title: @event.title)
    end

  end

  describe "Cancel Event" do
    background do
      user = create(:user, :lobby)
      login_as user
      clear_emails
      @event = create(:event, title: 'New event from Capybara', user: user)
      @event.update(status: 'accepted')
      @event.lobby_contact_email = 'test_lobby_mail'
      @event.cancel = 'true'
      @event.canceled_reasons = 'test'
      @event.lobby_activity = true
      @event.save!
      open_email(@event.lobby_contact_email)
    end

    scenario 'cancel event mail lobby' do
      expect(current_email).to have_content I18n.t('mailers.cancel_event.text1', title: @event.title)
    end

  end

  describe "Create Event" do
    background do
      user = create(:user, :user)
      login_as user
      clear_emails
      @event = create(:event, title: 'New event from Capybara', user: user,
                      current_user: user, lobby_contact_email: 'test@test', lobby_activity: true )
      open_email(@event.lobby_contact_email)
    end

    scenario 'create event mail' do
      expect(current_email).to have_content I18n.t('mailers.create_event.text1', title: @event.title)
    end

  end

  describe "Create Event" do
    background do
      user = create(:user, :lobby)
      login_as user
      clear_emails
      @event = create(:event, title: 'New event from Capybara', user: user,
                      current_user: user, lobby_contact_email: 'test@test', lobby_activity: true, status: "requested" )
      open_email(@event.lobby_contact_email)
    end

    scenario 'create event mail' do
      skip("pending test")
      expect(current_email).to have_content I18n.t('mailers.create_event.text1', title: @event.title)
    end

  end
end
