module Types
  module ClubPage
    Layout = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:content, :menu)
  end
end