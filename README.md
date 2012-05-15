Event Driven Architecture for Rails
===================================

The event_dispatcher gem for rails allows you to design and structure your application in terms of events, triggers,
actions and rules.

Why would you build for an Event Driven Architecture?
-----------------------------------------------------

Designing components based on events allows for more efficiency since parts of your system can be executed independently
and asynchronously. You simply only need to define an rule that will be executed when an event is "fired" and
event_dispatcher is responsible for executing the rule (or rules) in the most efficient way possible.

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

gem 'event_dispatcher'

2. Run the installation script

rails g event_dispatcher:install
rake db:migrate

Generators
===============

Generators are available to automatically generate triggers, actions and rules;

Examples:

rails g trigger payment_made
rails g action deliver_goods
rails g rule deliver_goods_when_payment_made