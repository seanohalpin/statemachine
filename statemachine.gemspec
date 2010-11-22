# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{statemachine}
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Micah Martin"]
  s.autorequire = %q{statemachine}
  s.date = %q{2010-11-22}
  s.description = %q{Statemachine is a ruby library for building Finite State Machines (FSM), also known as Finite State Automata (FSA).}
  s.email = %q{statemachine-devel@rubyforge.org}
  s.files = ["Rakefile", "LICENSE", "CHANGES", "README.rdoc", "TODO", "lib/statemachine/stub_context.rb", "lib/statemachine/version.rb", "lib/statemachine/action_invokation.rb", "lib/statemachine/superstate.rb", "lib/statemachine/state.rb", "lib/statemachine/generate/dot_graph.rb", "lib/statemachine/generate/java/java_statemachine.rb", "lib/statemachine/generate/java.rb", "lib/statemachine/generate/src_builder.rb", "lib/statemachine/generate/dot_graph/dot_graph_statemachine.rb", "lib/statemachine/generate/util.rb", "lib/statemachine/transition.rb", "lib/statemachine/builder.rb", "lib/statemachine/statemachine.rb", "lib/statemachine.rb", "spec/builder_spec.rb", "spec/sm_simple_spec.rb", "spec/sm_odds_n_ends_spec.rb", "spec/transition_spec.rb", "spec/sm_super_state_spec.rb", "spec/sm_entry_exit_actions_spec.rb", "spec/sm_turnstile_spec.rb", "spec/generate/java/java_statemachine_spec.rb", "spec/generate/dot_graph/dot_graph_stagemachine_spec.rb", "spec/action_invokation_spec.rb", "spec/sm_action_parameterization_spec.rb", "spec/default_transition_spec.rb", "spec/history_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://statemachine.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{statemachine}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Statemachine-1.1.1 - Statemachine Library for Ruby http://slagyr.github.com/statemachine}
  s.test_files = ["spec/builder_spec.rb", "spec/sm_simple_spec.rb", "spec/sm_odds_n_ends_spec.rb", "spec/transition_spec.rb", "spec/sm_super_state_spec.rb", "spec/sm_entry_exit_actions_spec.rb", "spec/sm_turnstile_spec.rb", "spec/action_invokation_spec.rb", "spec/sm_action_parameterization_spec.rb", "spec/default_transition_spec.rb", "spec/history_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
