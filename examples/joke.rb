#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'
require 'configliere'

Settings.use :commands

Settings.define_command :q1, :description => "The first joke (question)"
Settings.define_command :q2, :description => "The second joke (question)"
Settings.define_command :q3, :description => "The third joke (question)"

Settings.define_command :a1, :description => "The first joke (answer, all ages)"
Settings.define_command :a2, :description => "The second joke (answer, PG-13)" do |cmd|
  cmd.define :age_limit, :type => Integer,  :default => 12, :description => "minimum age to be able to enjoy joke 2"
end
Settings.define_command :a3, :description => "The third joke (answer, R)" do |cmd|
  cmd.define :age_limit, :type => Integer,  :default => 17, :description => "minimum age to be able to enjoy joke 3"
  cmd.define :bleep,     :type => :boolean, :default => false, :description => "if enabled, solecisms will be bowlerized"
end

Settings.define :debug,   :type => :boolean, :default => false, :description => "show verbose progress", :internal => true
Settings.define :age,     :type => Integer, :required => true,  :description => "Your age, in human years"
Settings.define :fake_id, :type => :boolean, :default => false, :description => "A fake ID might be enough to bypass the age test"

class Clown

  def q1
    "what do you call a deer with no eyes?"
  end

  def a1
    "no-eye deer"
  end

  def q2
    "what do you call a dead deer with no eyes?"
  end

  def a2
    "still no-eye deer"
  end

  def q3
    "what do you call a dead, castrated deer with no eyes?"
  end

  def a3
    "still no-#{Settings[:bleep] ? 'bleeping' : 'fucking'} no-eye deer"
  end

  def check_age_limit!
    return if not Settings[:age_limit]
    if (Settings.age < Settings[:age_limit]) && (not Settings[:fake_id])
      warn "Sorry kid, you're too young for this joke. Try this again when you're older (or maybe ask for --help)"
      exit(1)
    end
  end

  def check_command!
    if not Settings.command_name
      Settings.die "Which joke would you like to hear?"
    end
  end

  def run
    check_command!
    check_age_limit!
    self.public_send(Settings.command_name)
  end
end

Settings.resolve!

if Settings.debug
  puts "   -- received command #{Settings.command_name}, settings #{Settings}"
  puts ""
  puts ""
end


puts Clown.new.run
