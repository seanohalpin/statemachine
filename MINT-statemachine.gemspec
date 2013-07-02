# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "MINT-statemachine"
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sebastian Feuerstack"]
  s.date = "2013-07-02"
  s.description = "The MINT Statemachine is a ruby library for building Finite State Machines, based on the Statemachine gem by Micah Martin."
  s.email = "Sebastian@Feuerstack.org"
  s.files = ["TODO", "Gemfile.lock", "LICENSE", "CHANGES", "Rakefile", "Gemfile", "README.rdoc", "MINT-statemachine.gemspec", "lib/statemachine.rb", "lib/statemachine/builder.rb", "lib/statemachine/statemachine.rb", "lib/statemachine/generate/util.rb", "lib/statemachine/generate/dot_graph/dot_graph_statemachine.rb", "lib/statemachine/generate/java/java_statemachine.rb", "lib/statemachine/generate/dot_graph.rb", "lib/statemachine/generate/src_builder.rb", "lib/statemachine/generate/java.rb", "lib/statemachine/transition.rb", "lib/statemachine/version.rb", "lib/statemachine/parallelstate.rb", "lib/statemachine/action_invokation.rb", "lib/statemachine/superstate.rb", "lib/statemachine/state.rb", "lib/statemachine/stub_context.rb", "spec/default_transition_spec.rb", "spec/spec_helper.rb", "spec/sm_super_state_spec.rb", "spec/sm_action_parameterization_spec.rb", "spec/generate/dot_graph/dot_graph_stagemachine_spec.rb", "spec/generate/java/java_statemachine_spec.rb", "spec/sm_entry_exit_actions_spec.rb", "spec/sm_simple_spec.rb", "spec/sm_parallel_state_spec.rb", "spec/transition_spec.rb", "spec/noodle.rb", "spec/sm_activation_spec.rb", "spec/builder_spec.rb", "spec/action_invokation_spec.rb", "spec/sm_turnstile_spec.rb", "spec/history_spec.rb", "spec/sm_odds_n_ends_spec.rb"]
  s.homepage = "http://www.multi-access.de"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "MINT-Statemachine-1.4.1 - Statemachine Library for Ruby based on statemachine from http://slagyr.github.com/statemachine http://www.multi-access.de/open-source-software/third-party-software-extensions/"
  s.test_files = ["spec/default_transition_spec.rb", "spec/sm_super_state_spec.rb", "spec/sm_action_parameterization_spec.rb", "spec/sm_entry_exit_actions_spec.rb", "spec/sm_simple_spec.rb", "spec/sm_parallel_state_spec.rb", "spec/transition_spec.rb", "spec/sm_activation_spec.rb", "spec/builder_spec.rb", "spec/action_invokation_spec.rb", "spec/sm_turnstile_spec.rb", "spec/history_spec.rb", "spec/sm_odds_n_ends_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
