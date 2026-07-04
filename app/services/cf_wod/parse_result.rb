module CfWod
  ParseResult = Data.define(:workout, :status, :reason, :raw_text) do
    def parsed? = status == :parsed
    def partial? = status == :partial
    def failed? = status == :failed
  end
end
