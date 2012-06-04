require 'spec_helper'

module EventTriggers
  class TestTrigger < EventDispatcher::Trigger
    ENTITY_TYPE = 0

    trigger_name "TestTrigger"
    description "Trigger used in the test"
    listens_to :test
  end

#both test and fave must be dispatched at the same time for this trigger to happen
  class MultiEventTrigger < EventDispatcher::Trigger
    ENTITY_TYPE = 100

    trigger_name "MultiEventTrigger"
    description "Trigger used in the test"

    listens_to :test, :fave
  end

#both test and fave must be dispatched at the same time for this trigger to happen
  class PorkTestTrigger < EventDispatcher::Trigger
    ENTITY_TYPE = 101

    trigger_name "MultiEventTrigger"
    description "Trigger used in the test"

    listens_to :pork
  end

  class TriggerThatHasParameters < EventDispatcher::Trigger
    ENTITY_TYPE = 102

    trigger_name "MultiEventTrigger"
    description "Trigger used in the test"

    listens_to :beef

    has_parameter :test_trigger_param, :integer, :required=>true

    def conditions_met?
      test_trigger_param
    end

  end

  class TriggerThatHasParameters2 < EventDispatcher::Trigger
    ENTITY_TYPE = 103

    trigger_name "MultiEventTrigger"
    description "Trigger used in the test"

    listens_to :chicken

    has_parameter :test_trigger_param, :integer, :required=>true

    def conditions_met?
      test_trigger_param
    end

  end

  class TriggerThatListensToNone < EventDispatcher::Trigger

    ENTITY_TYPE = 104

    trigger_name "TriggerThatListensToNone"
    description "Trigger used in the test"

    has_parameter :points, :integer, :default=>123
    listens_to :none

    def conditions_met?
      {actor: actor, subject: subject, extras: extras, points: points}
    end

  end

  class TriggerForTesting < TriggerThatListensToNone
    ENTITY_TYPE = 105

    listens_to :test_event9

    has_parameter :points, :string

  end

  class AfterTriggerTest < EventDispatcher::Trigger
    ENTITY_TYPE = 106

    listens_to :test_event10

    has_parameter :fail_it, :boolean, :default => :false

    def conditions_met?
      !fail_it
    end

    def after_trigger
    end

  end

  class AfterTriggerTest2 < EventDispatcher::Trigger

    ENTITY_TYPE = 107

    listens_to :test_event11

    has_parameter :fail_it, :boolean, :default => :false

    def conditions_met?
      !fail_it
    end

    def after_trigger
    end
  end

end

module EventActions
  class TestActionWithParameters < EventDispatcher::EventAction

    ENTITY_TYPE = 300

    action_name "TestActionWithParameters"
    description "An action to test a sample action"

    has_parameter :points, :integer, :default=>100
    has_parameter :sample_string, :string, :required=>true

    def perform()
      {points: points, sample_string: sample_string}
    end

  end
end

class TestEventRule < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 1000
  use_trigger :test_trigger
end

class MultiEventTextRule < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 1001
  use_trigger :multi_event_trigger
end

class ActionReuseRule < EventDispatcher::EventRuleBase

  ENTITY_TYPE = 1002

  listens_to :chicken

  has_parameter :points, :integer, :default=>'100'

  def perform(actor, subject, extras = {})
    do_action :test_action_with_parameters, actor, subject, {points: 9271982, sample_string: 'HELLOWORLD!!!'}
  end
end

class TestParameterRule < EventDispatcher::EventRuleBase

  ENTITY_TYPE = 202

  listens_to :test_event

  has_parameter :param_test1, :string, :required=>true

  def perform(actor, subject, extras = {})
    param_test1
  end

end

class TestParameterIntegerRule < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 203

  listens_to :test_event2

  has_parameter :integer_param_test, :integer

  def perform(actor, subject, extras = {})
    integer_param_test
  end

end

class RuleThatThrowsException < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 204

  listens_to :test_event3

  def perform(actor, subject, extras = {})
    raise Exception.new
  end

end

class RuleThatListensToMultipleEvents < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 205

  listens_to :test_event4
  listens_to :test_event5
  listens_to :test_event6, :test_event7

  def perform(actor, subject, extras = {})
  end
end

class RuleThatUsesTriggers < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 206

  listens_to :test_event8
  use_trigger :trigger_that_listens_to_none, {points: 100}


  def perform(actor, subject, extras = {})
    log "look I did something!!!!"
  end

end

class RuleThatShouldntBeCalled < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 207

end

class RuleThatUsesTriggersWithConfigurableParameters < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 208

  listens_to :test_event9
  has_parameter :trigger_param, :string

  use_trigger :trigger_for_testing, {points: trigger_param}

  def perform(actor, subject, extras = {})

  end
end

class RuleThatUsesTriggersWithSideEffect < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 209

  listens_to :test_event10
  use_trigger :after_trigger_test

  def after_trigger

  end

end

class RuleThatUsesCustomTriggerMethods < EventDispatcher::EventRuleBase
  ENTITY_TYPE = 210

  listens_to :test_event11

  conditions_method :some_freaky_condition

  def some_freaky_condition(events, actor, subject, extras)
    extras[:return_value]
  end

  def perform(actor, subject, extras = {})

  end

end

describe EventDispatcher do
  context "engine" do
    it "lists all events that rules and triggers listen to" do
      result = ([:all, :avatar_created,
      :beef, :chicken, :fave, :friend_request_accepted,
      :game_invite, :none, :play_game, :pork, :profile_update,
      :test, :test_event, :test_event10, :test_event11,
      :test_event2, :test_event3, :test_event4, :test_event5,
      :test_event6, :test_event7, :test_event8, :test_event9,
      :unfave, :user_login, :wall_post] - EventDispatcher::Engine.get_events_listened_to)
      result.empty?.should be
    end

    it "lists all rules to be executed per event" do
      EventDispatcher::Engine.get_rules_by_events([:fave]).should == [{:event=>:fave, :rules=>["fave get points", "EventRules::AppFaveRule"]}]
      EventDispatcher::Engine.get_rules_by_events([:test_event]).should == [{:event=>:test_event, :rules=>["TestParameterRule"]}]
    end
  end

  it_should_behave_like "events"

  describe "#dispatch_event" do
    let(:avatar) { avatars(:avatar1_user1_jay) }
    let(:app) { apps(:boomz_app) }
    let(:rule) { rules(:fave_rule) }

    before :each do
      mock.any_instance_of(RuleThatShouldntBeCalled).perform.never
      stub.any_instance_of(EventDispatcher::Config).disable_all { false }
    end

    it "Loads all applicable triggers" do
      EventDispatcher::Backend.send(:get_applicable_triggers, [:fave]).should == [EventTriggers::FaveTrigger]
    end

    it "loads all applicable rules" do
      mock.any_instance_of(EventTriggers::FaveTrigger).conditions_met?.once
      mock.any_instance_of(EventTriggers::UnfaveTrigger).conditions_met?.never
      EventDispatcher::Engine.fire([:fave], avatar, app)
    end

    context "real time rules" do

      before do
        stub(EventDispatcher::Backend).get_built_in_rules.returns { {} }
      end

      it "executes the actions of applicable rules" do
        proxy.any_instance_of(Rule).perform(avatar, app, anything).once
        mock.any_instance_of(EventActions::AddPointsAction).perform.once
        mock.any_instance_of(EventActions::SubtractPointsAction).perform.never
        EventDispatcher::Engine.fire([:fave], avatar, app)
      end

    end

    context "built in rules" do

      before do
        stub(EventDispatcher::Backend).get_active_rules(anything, anything).returns({})
      end

      it "executes multiple rules " do
        mock.any_instance_of(TestEventRule).perform(avatar, app, anything)
        mock.any_instance_of(EventActions::AddPointsAction).perform.once
        mock.any_instance_of(EventActions::SubtractPointsAction).perform.never

        EventDispatcher::Engine.fire([:test, :fave], avatar, app)
      end
    end


    it "executes built-in rules (Rules that are hardcoded)" do
      mock.any_instance_of(TestEventRule).perform(avatar, app, anything)
      proxy.any_instance_of(Rule).perform.never
      EventDispatcher::Engine.fire([:test], avatar, app)
    end


    it "does not execute disabled rules" do
      rule.enabled = false
      rule.save!
      proxy.any_instance_of(Rule).perform(avatar, app, {}).never
      EventDispatcher::Engine.fire([:fave], avatar, app)
    end

    it "catches and displays exceptions" do
      lambda {
        mock.any_instance_of(EventDispatcher::EventRuleBase).log_error(anything, anything, anything, anything, anything)
        EventDispatcher::Engine.fire([:test_event3], avatar, app)
      }.should raise_exception(Exception)
    end

    context "actions" do

      before do
        test_rule = Rule.create(name: 'Test rule')

        test_rule.rule_triggers.create(trigger_type: EventTriggers::PorkTestTrigger::ENTITY_TYPE)
        test_action = test_rule.rule_actions.create(action_type: EventActions::TestActionWithParameters::ENTITY_TYPE)
        test_action.action_parameters.create(name: 'points', value: '100')
        test_action.action_parameters.create(name: 'sample_string', value: 'DEADBEEF!!!')
      end

      it "actions can load parameters" do

        mock.proxy.any_instance_of(EventActions::TestActionWithParameters).perform.once do |result|
          result.should == {points: 100, sample_string: 'DEADBEEF!!!'}
        end
        EventDispatcher::Engine.fire(:pork, avatar, app)
      end
    end

    context "triggers" do
      it "triggers can load parameters" do
        test_rule = Rule.create(name: 'Test rule')
        rule_trigger = test_rule.rule_triggers.create(trigger_type: EventTriggers::TriggerThatHasParameters::ENTITY_TYPE)
        rule_trigger.trigger_parameters.create(name: 'test_trigger_param', value: '100')

        mock.proxy.any_instance_of(EventTriggers::TriggerThatHasParameters).conditions_met?.once do |result|
          result.should == 100
        end

        EventDispatcher::Engine.fire(:beef, avatar, app)
      end

      it "if one trigger fails the rule does not get executed" do
        test_rule = Rule.create(name: 'Test rule')
        rule_trigger = test_rule.rule_triggers.create(trigger_type: EventTriggers::AfterTriggerTest::ENTITY_TYPE)
        rule_trigger.trigger_parameters.create(name: 'fail_it', value: 'true')
        mock.any_instance_of(Rule).perform.never
        EventDispatcher::Engine.fire(:test_event10, avatar, app)
      end

      context "#after_trigger" do

        context "build-in rules" do
          it "calls after_trigger when all conditions are met" do
            mock.any_instance_of(EventTriggers::AfterTriggerTest).after_trigger.once
            EventDispatcher::Engine.fire(:test_event10, avatar, app)
          end

          it "does not call when conditions have not been met" do
            RuleParameter.create(entity_id: nil, entity_type: TestParameterRule::ENTITY_TYPE, name: 'fail_it', value: 'true')
            mock.any_instance_of(EventTriggers::AfterTriggerTest).conditions_met?.once
            mock.any_instance_of(EventTriggers::AfterTriggerTest).after_trigger.never
            EventDispatcher::Engine.fire(:test_event10, avatar, app)
          end
        end

        context "user rules" do

          before do
            test_rule = Rule.create(name: 'Test rule')
            rule_trigger = test_rule.rule_triggers.create(trigger_type: EventTriggers::AfterTriggerTest2::ENTITY_TYPE)
            rule_trigger.trigger_parameters.create(name: 'fail_it', value: 'false')
          end

          it "calls after_trigger when all conditions are met" do
            mock.any_instance_of(EventTriggers::AfterTriggerTest2).after_trigger.once
            EventDispatcher::Engine.fire(:test_event11, avatar, app)
          end

        end
      end

    end

    context "Triggers that rely on multiple events at the same time" do

      context "does not trigger" do

        it "if only :test" do
          mock.any_instance_of(MultiEventTextRule).perform.never
          EventDispatcher::Engine.fire([:test], avatar, app)
        end

        it "if only :fave" do
          mock.any_instance_of(MultiEventTextRule).perform.never
          EventDispatcher::Engine.fire([:fave], avatar, app)
        end
      end

      context "triggers" do
        it "if both :test and :fave are thrown" do
          mock.any_instance_of(MultiEventTextRule).perform(avatar, app, anything)
          EventDispatcher::Engine.fire([:test, :fave], avatar, app)
        end
      end

    end

    context "Built-in rules" do

      it "Loads the parameters correctly" do

        RuleParameter.create(entity_id: nil, entity_type: TestParameterRule::ENTITY_TYPE, name: 'param_test1', value: 'DEAD BEEF!!!!')
        mock.proxy.any_instance_of(TestParameterRule).perform(avatar, app, anything) do |result|
          result.should == 'DEAD BEEF!!!!'
        end

        EventDispatcher::Engine.fire([:test_event], avatar, app)
      end

      it "required parameters should throw an exception when there are no values" do
        lambda {
          EventDispatcher::Engine.fire([:test_event], avatar, app)
        }.should raise_exception(EventDispatcher::RequiredParameterException)
      end

      it "data type of integer automatically converts it into an integer" do
        RuleParameter.create(entity_id: nil, entity_type: TestParameterIntegerRule::ENTITY_TYPE, name: 'integer_param_test', value: '555777')
        mock.proxy.any_instance_of(TestParameterIntegerRule).perform(avatar, app, anything) do |result|
          result.should == 555777
        end
        EventDispatcher::Engine.fire([:test_event2], avatar, app)
      end

      it "can access parameter values directly" do
        RuleParameter.create(entity_id: nil, entity_type: TestParameterIntegerRule::ENTITY_TYPE, name: 'integer_param_test', value: '555888')
        TestParameterIntegerRule.integer_param_test_value.should == 555888
      end

      it "built-in rules can directly pass parameters to actions" do

        mock.proxy.any_instance_of(EventActions::TestActionWithParameters).perform do |result|
          result.should == {points: 9271982, sample_string: 'HELLOWORLD!!!'}
        end

        EventDispatcher::Engine.fire(:chicken, avatar, app)
      end

      it "build-in rules can listen to multiple events (act as an OR operation)" do
        mock.any_instance_of(RuleThatListensToMultipleEvents).perform(anything, anything, anything).times(2)

        EventDispatcher::Engine.fire(:test_event4, avatar, app)
        EventDispatcher::Engine.fire(:test_event5, avatar, app)
      end

      it "evaluates events on the same listens_to line as AND" do
        mock.any_instance_of(RuleThatListensToMultipleEvents).perform(anything, anything, anything).times(1)
        EventDispatcher::Engine.fire(:test_event6, avatar, app)
        EventDispatcher::Engine.fire([:test_event6, :test_event7], avatar, app)
      end

      context "performance" do
        it "queries parameters only once from the db per rule instance" do
          RuleParameter.create(entity_id: nil, entity_type: TestParameterRule::ENTITY_TYPE, name: 'param_test1', value: 'DEAD BEEF!!!!')
          rule = TestParameterRule.new
          proxy(TestParameterRule).load_parameter(:param_test1, 202, :string, {:required=>true}).once
          rule.perform( avatar, app)
          rule.perform( avatar, app)
        end
      end

      context "custom trigger methods" do

        it "rule fails if the method returns false" do
          mock.any_instance_of(RuleThatUsesCustomTriggerMethods).perform.never
          EventDispatcher::Engine.fire(:test_event11, avatar, app, {return_value: false})
        end

        it "rule executes if the method returns true" do
          mock.any_instance_of(RuleThatUsesCustomTriggerMethods).perform(anything, anything, anything).once
          EventDispatcher::Engine.fire(:test_event11, avatar, app, {return_value: true})
        end
      end

      context "can reuse built-in triggers" do

        let(:avatar) { avatars(:avatar1_user1_jay) }
        let(:app) { apps(:boomz_app) }
        it "passes parameters correctly to triggers" do
          mock.proxy.any_instance_of(EventTriggers::TriggerThatListensToNone).conditions_met? do |result|
            result.should == {actor: avatar, subject: app, extras: {}, points: 100}
          end
          mock.any_instance_of(RuleThatUsesTriggers).perform(anything, anything, anything).times(1)
          EventDispatcher::Engine.fire(:test_event8, avatar, app)
        end

        it "passes configurable parameters correctly to triggers do" do
          RuleParameter.create(entity_id: nil, rule_id: nil, entity_type: RuleThatUsesTriggersWithConfigurableParameters::ENTITY_TYPE, name: 'trigger_param', value: 'TRIGGERPARAMTEST')
          mock.proxy.any_instance_of(EventTriggers::TriggerForTesting).conditions_met? do |result|
            result.should == {actor: avatar, subject: app, extras: {}, points: 'TRIGGERPARAMTEST'}
          end
          mock.any_instance_of(RuleThatUsesTriggersWithConfigurableParameters).perform(anything, anything, anything).times(1)
          EventDispatcher::Engine.fire(:test_event9, avatar, app)
        end

        it "evaluates use_trigger to call the actual triggers" do
          mock.any_instance_of(EventTriggers::TriggerThatListensToNone).conditions_met?.at_least(1).returns { true }
          mock.any_instance_of(RuleThatUsesTriggers).perform(anything, anything, anything).times(1)
          EventDispatcher::Engine.fire(:test_event8, avatar, app)
        end
      end
    end
  end

  context "EventDispatcher configuration" do

    def get_rules
      EventDispatcher::Engine.dispatch_backend.send(:get_built_in_rules).keys.map { |k| k.constantize }
    end

    it "has defaults" do
      config = EventDispatcher::Config.new
      config.logger_backend.should == EventDispatcher::MemcacheEventLog
      config.disable_all.should == false
      config.event_log.should == false
    end

    it "can whitelist " do
      EventDispatcher::Engine.config do |config|
        config.disable_all = true
        config.enabled = [:rule_that_uses_triggers]
      end
      get_rules.should == [RuleThatUsesTriggers]
    end

    it "can blacklist" do
      EventDispatcher::Engine.config do |config|
        config.disabled = [:rule_that_uses_triggers]
      end
      get_rules.should_not include RuleThatUsesTriggers
    end

    it "executes all by default" do
      EventDispatcher::Engine.config do |config|
      end
      ([EventRules::AppFaveRule, EventRules::AppUnfaveRule,
        EventRules::AvatarInfoUpdateRule, EventRules::CreateAvatarRule,
        EventRules::FriendRequestRule, EventRules::FriendWallPostRule, EventRules::GameInviteRule,
        EventRules::GamePlayPointsRule, EventRules::UserLoginRule, TestEventRule, MultiEventTextRule,
        ActionReuseRule, TestParameterRule, TestParameterIntegerRule, RuleThatThrowsException,
        RuleThatListensToMultipleEvents, RuleThatUsesTriggers, RuleThatShouldntBeCalled,
        RuleThatUsesTriggersWithConfigurableParameters, RuleThatUsesTriggersWithSideEffect] - get_rules).empty?.should be
    end
  end

  context "EventDispatcher::Backend" do

    let(:avatar) { avatars(:avatar1_user1_jay) }
    let(:app) { apps(:boomz_app) }
    let(:backend) { EventDispatcher::Engine.dispatch_backend }

    before do
      stub.any_instance_of(EventDispatcher::Config).event_log { true }
      stub.any_instance_of(EventDispatcher::Config).disable_all { false }
    end

    it "has access to configs" do
      backend.config.should be
    end

    context "logging" do

      it "has access to logging" do
        backend.send(:get_logger, "something").should be
      end

      it "logs rules being executed" do
        mock.any_instance_of(EventDispatcher::MemcacheEventLog).log(anything).any_number_of_times
        EventDispatcher::Engine.fire(:test_event8, avatar, app)
      end
    end

  end
end
