Event Driven Architecture for Rails
===================================

The event_dispatcher gem for rails allows you to design and structure your application in terms of events, triggers,
actions and rules.

Why would you build for an Event Driven Architecture for Rails?
-----------------------------------------------------

Designing components based on events allows for more efficiency since parts of your system can be executed independently
and asynchronously. You simply only need to define an rule that will be executed when an event is "fired" and
event_dispatcher is responsible for executing the rule (or rules) in the most efficient way possible.

The event_dispatcher gem works well for encapsulating independent activities that do directly participate in the rendering
of the page (e.g. posting to google analytics, performance data, logging or background tasks)

Events, Triggers, Rules and Actions
-----------------------------------

Events - Events are fired from specific points in your application. In most cases you will most likely place this
  somewhere in your controllers or models

Triggers - Triggers are conditions that would initiate a set of actions. For example if a trigger is configured to
  listen to the :buy_item event it will be called when a :buy_item event is fired. Triggers are not limited to listnening
  to events and are also able to evaluate a lot more complex conditions as well

Actions - Actions refer to the payload to be executed when a trigger is activated. They can perform various tasks like
  updating the database or firing other events.

Rules - Rules are simply objects that link triggers and actions together. They usually define a business requirement that
  your application needs to fulfill.

Installing the event_dispatcher GEM
===================================

1. Include the following line in your Gemfile and then run bundle

--------------------------------------------------------------------------------
gem 'event_dispatcher'
--------------------------------------------------------------------------------

2. Run the installation script

--------------------------------------------------------------------------------
rails g event_dispatcher:install
rake db:migrate
--------------------------------------------------------------------------------

Generators
===============

Generators are available to automatically generate triggers, actions and rules;

Examples:

--------------------------------------------------------------------------------
rails g event_dispatcher:trigger payment_made
rails g event_dispatcher:action deliver_goods
rails g event_dispatcher:rule deliver_goods_when_payment_made
--------------------------------------------------------------------------------

Guide to Creating your first rule
=================================

A rule contains the specific business requirement and contains both the trigger (what condition to listen for) and
the action (what are the specific steps that needs to be done):

-------------------------------------------------------------------------------------
 rails g event_dispatcher:rule say_hello_when_logged_in log_in
   create  app/models/event_rules/say_hello_when_logged_in_rule.rb
-------------------------------------------------------------------------------------

This creates a rule that listens to the :log_in event.

The rule looks like this:

--------------------------------------------------------------------------------------
module EventRules
  class SayHelloWhenLoggedInRule < EventDispatcher::Core::EventRuleBase

    ENTITY_TYPE = 1

    listens_to :log_in

    def perform(actor, subject, extras = {})
      # Place the stuff that your rule does here
    end

  end
end
----------------------------------------------------------------------------------------


Please your payload (things to do in the perform block)

----------------------------------------------------------------------------------------
def perform(actor, subject, extras = {})
   say "Hello"
end
----------------------------------------------------------------------------------------

Then somewhere in your controller, trigger the event by using fire_event. You can also pass
the actor and subject in case you want your rules to have access to some form of context...

----------------------------------------------------------------------------------------
def login_action
  fire_event :log_in, current_user
end
----------------------------------------------------------------------------------------

If you want to have a convenient list of rules there is a handy rake task for that

----------------------------------------------------------------------------------------
rake event_dispatcher:list
----------------------------------------------------------------------------------------

That's it!
