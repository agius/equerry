module Equerry
  module Utils
    class Options < Hash
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::DeepFetch
    end
  end
end