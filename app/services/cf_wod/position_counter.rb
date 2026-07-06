module CfWod
  class PositionCounter
    def initialize
      @value = 0
    end

    def next!
      @value += 1
    end
  end
end
