Event Driven Architecture for Rails
===================================

The event_dispatcher gem for rails allows you to design and structure your application in terms of events, triggers,
actions and rules. It also supports for defining these rules even during runtime by allowing you to store rules
(and its triggers and actions) inside the database.

Why would you build for an Event Driven Architecture for Rails?
-----------------------------------------------------

Designing components based on events allows for more efficiency since parts of your system can be executed independently
and asynchronously. You simply only need to define an rule that will be executed when an event is "fired" and
event_dispatcher is responsible for executing the rule (or rules) in the most efficient way possible.

The event_dispatcher gem works well for encapsulating independent activities that do directly participate in the rendering
of the page (e.g. posting to google analytics, performance data, logging or background tasks). As it also allows for
changing behavior during runtime it is useful for product managers and/or testers to test out behaviour in a test
or staging environment. Even more, it also makes it easy to define runtime parameters that can be easily changed by
users or administrators of the system.

Events, Triggers, Rules and Actions
-----------------------------------

Some terms to define:

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

Include the following line in your Gemfile and then run bundle

````````````````````````````````````````````````````````````````````````````````````
gem 'event_dispatcher'
````````````````````````````````````````````````````````````````````````````````````

Run the installation script

````````````````````````````````````````````````````````````````````````````````````
rails g event_dispatcher:install
rake db:migrate
````````````````````````````````````````````````````````````````````````````````````

Generators
===============

Generators are available to automatically generate triggers, actions and rules;

Examples:

````````````````````````````````````````````````````````````````````````````````````
rails g event_dispatcher:trigger payment_made
rails g event_dispatcher:action deliver_goods
rails g event_dispatcher:rule deliver_goods_when_payment_made
````````````````````````````````````````````````````````````````````````````````````

Guide to Creating your first static rule
=================================

A static rule contains the specific business requirement and contains both the trigger
(what condition to listen for) and the action(s) to be executed (what are the
specific steps that needs to be done). There are also "runtime defined" rules in which
the connection between the trigger and the action is defined instead in the database. For development
purposes it is recommended to use static rules since they can be easily included in your
test suite...

To start:

````````````````````````````````````````````````````````````````````````````````````
 rails g event_dispatcher:rule say_hello_when_logged_in log_in
   create  app/models/event_rules/say_hello_when_logged_in_rule.rb
````````````````````````````````````````````````````````````````````````````````````

This creates a rule that listens to the :log_in event.

The rule looks like this:

````````````````````````````````````````````````````````````````````````````````````
module EventRules
  class SayHelloWhenLoggedInRule < EventDispatcher::Core::EventRuleBase

    ENTITY_TYPE = 1

    listens_to :log_in

    def perform(actor, subject, extras = {})
      # Place the stuff that your rule does here
    end

  end
end
````````````````````````````````````````````````````````````````````````````````````


Add code to your payload (things to do in the perform block)

````````````````````````````````````````````````````````````````````````````````````
def perform(actor, subject, extras = {})
   say "Hello"
end
````````````````````````````````````````````````````````````````````````````````````

Then somewhere in your controller, trigger the event by using fire_event. You can also pass
the actor and subject in case you want your rules to have access to some form of context...

````````````````````````````````````````````````````````````````````````````````````
def login_action
  fire_event :log_in, current_user
end
````````````````````````````````````````````````````````````````````````````````````

That's it! The are a lot more to Rules this the example above is the simplest to execute.

If you want to have a convenient list of rules there is a handy rake task for that

````````````````````````````````````````````````````````````````````````````````````
rake event_dispatcher:list

Events:
-------------------------------
add_points:
     EventRules::AddPointsRule


-------------------------------
log_in:
     EventRules::SayHelloWhenLoggedInRule
````````````````````````````````````````````````````````````````````````````````````

Parameters
----------

Your rules can also have parameters (or configuration), event_dispatcher automatically handles the retrieval of
these parameters form the database.

````````````````````````````````````````````````````````````````````````````````````````````````````````
has_parameter :login_threshold, :integer, :default=>5, :description => 'Threshold before user is awarded points'
````````````````````````````````````````````````````````````````````````````````````````````````````````

This defines a parameter login_threshold, you can use this directly in your perform block like

````````````````````````````````````````````````````````````````````````````````````
def perform(actor, subject, extras = {})
   if actor.logins > login_threshold
       #Do something
   end
end
````````````````````````````````````````````````````````````````````````````````````

Note also that Triggers and Actions also support this.

Creating Triggers and Actions
=================================

While Rules can already contain both the triggers and actions, you can also define standalone Triggers and Actions.
Defining them separately allows other rules to reuse the same trigger and action (DRY), also it allows these
Triggers and Actions to be used by "runtime defined" rules.

Triggers
--------

Triggers are classes that are responsible for only one thing... determine if an event has happened. They can be as simple
as listening to an event, evaluate a certain condition like if a user has met a certain criteria or a combination of both.


````````````````````````````````````````````````````````````````````````````````````
event_dispatcher:trigger user_has_logged_in_x_times
````````````````````````````````````````````````````````````````````````````````````

If the trigger is to listen to an event, you may include it also

````````````````````````````````````````````````````````````````````````````````````
event_dispatcher:trigger user_has_logged_in_x_times user_logged_in_event
  create  app/models/event_triggers/user_has_logged_in_x_times_trigger.rb
````````````````````````````````````````````````````````````````````````````````````

This should generate something like this:

````````````````````````````````````````````````````````````````````````````````````
module EventTriggers
  class UserHasLoggedInXTimesTrigger < EventDispatcher::Core::Trigger

    ENTITY_TYPE = 1

    trigger_name "Name of action here"
    description "Place what your action does here"


    listens_to :user_logged_in_event

    def conditions_met?
      #put stuff to evaluate here and return true if it satisfies the conditions
      true
    end

  end
end
````````````````````````````````````````````````````````````````````````````````````

you can then reuse this in your Rule by:

````````````````````````````````````````````````````````````````````````````````````
use_trigger :user_has_logged_in_x_times
````````````````````````````````````````````````````````````````````````````````````

So:

````````````````````````````````````````````````````````````````````````````````````
module EventRules
  class SayHelloWhenLoggedInRule < EventDispatcher::Core::EventRuleBase

    ENTITY_TYPE = 1

    use_trigger :user_has_logged_in_x_times

    def perform(actor, subject, extras = {})
      # Place the stuff that your rule does here
    end

  end
end
````````````````````````````````````````````````````````````````````````````````````

