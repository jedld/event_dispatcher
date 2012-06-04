require 'spec_helper'

describe EventDispatcher::EventDispatcherWorker do
  context "when the resque worker is called" do

    let(:avatar) { avatars(:avatar1_user1_jay) }
    let(:app) { apps(:boomz_app) }

    before do
      mock(EventDispatcher::Backend).dispatch([:test], avatar, app, {})
    end

    it "#perform" do
      EventDispatcher::EventDispatcherWorker.perform([:test], avatar, app, {})
    end

  end
end