require 'spec_helper'

describe EventDispatcher::ResqueBackend do
  context "when the resque dispatcher is used" do

    let(:avatar) { avatars(:avatar1_user1_jay) }
    let(:app) { apps(:boomz_app) }

    before do
      mock(EventDispatcher::Engine).dispatch_backend.returns { EventDispatcher::ResqueBackend}
    end

    it "Creates a resque Job when an event is fired" do
      mock(Resque).enqueue(anything, [:test], anything, anything, anything)
      EventDispatcher::Engine.fire(:test, avatar, app)
    end

  end
end