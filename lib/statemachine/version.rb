module Statemachine
  module VERSION #:nodoc:
    unless defined? MAJOR
      MAJOR  = 1
      MINOR  = 4
      TINY   = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
      TAG    = "REL_" + [MAJOR, MINOR, TINY].join('_')

      NAME   = "MINT-Statemachine"
      URL    = "http://www.multi-access.de/open-source-software/third-party-software-extensions/"  
    
      DESCRIPTION = "#{NAME}-#{STRING} - Statemachine Library for Ruby based on statemachine from http://slagyr.github.com/statemachine\n#{URL}"
    end
  end
end
