# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{MINT-statemachine}
  s.version = "1.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Sebastian Feuerstack}]
  s.date = %q{2011-06-30}
  s.description = %q{The MINT Statemachine is a ruby library for building Finite State Machines, based on the Statemachine gem by Micah Martin.}
  s.email = %q{Sebastian@Feuerstack.org}
  s.files = [%q{Rakefile}, %q{README.rdoc}, %q{CHANGES}, %q{TODO}, %q{LICENSE}, %q{lib/statemachine/generate/java/java_statemachine.rb}, %q{lib/statemachine/generate/src_builder.rb}, %q{lib/statemachine/generate/java.rb}, %q{lib/statemachine/generate/dot_graph.rb}, %q{lib/statemachine/generate/util.rb}, %q{lib/statemachine/generate/dot_graph/dot_graph_statemachine.rb}, %q{lib/statemachine/transition.rb}, %q{lib/statemachine/superstate.rb}, %q{lib/statemachine/version.rb}, %q{lib/statemachine/statemachine.rb}, %q{lib/statemachine/stub_context.rb}, %q{lib/statemachine/state.rb}, %q{lib/statemachine/parallelstate.rb}, %q{lib/statemachine/action_invokation.rb}, %q{lib/statemachine/builder.rb}, %q{lib/statemachine.rb}, %q{spec/sm_turnstile_spec.rb}, %q{spec/generate/java/java_statemachine_spec.rb}, %q{spec/generate/dot_graph/dot_graph_stagemachine_spec.rb}, %q{spec/sm_odds_n_ends_spec.rb}, %q{spec/noodle.rb}, %q{spec/sm_entry_exit_actions_spec.rb}, %q{spec/default_transition_spec.rb}, %q{spec/action_invokation_spec.rb}, %q{spec/sm_parallel_state_spec.rb}, %q{spec/builder_spec.rb}, %q{spec/sm_activation_spec.rb}, %q{spec/sm_super_state_spec.rb}, %q{spec/transition_spec.rb}, %q{spec/spec_helper.rb}, %q{spec/sm_simple_spec.rb}, %q{spec/sm_action_parameterization_spec.rb}, %q{spec/history_spec.rb}]
  s.homepage = %q{http://www.multi-access.de}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{MINT-Statemachine-1.2.2 - Statemachine Library for Ruby based on statemachine from http://slagyr.github.com/statemachine http://www.multi-access.de/open-source-software/third-party-software-extensions/}
  s.test_files = [%q{spec/sm_turnstile_spec.rb}, %q{spec/sm_odds_n_ends_spec.rb}, %q{spec/sm_entry_exit_actions_spec.rb}, %q{spec/default_transition_spec.rb}, %q{spec/action_invokation_spec.rb}, %q{spec/sm_parallel_state_spec.rb}, %q{spec/builder_spec.rb}, %q{spec/sm_activation_spec.rb}, %q{spec/sm_super_state_spec.rb}, %q{spec/transition_spec.rb}, %q{spec/sm_simple_spec.rb}, %q{spec/sm_action_parameterization_spec.rb}, %q{spec/history_spec.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
