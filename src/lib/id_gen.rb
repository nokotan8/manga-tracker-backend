class IdGen
  def self.generate
    parts1 = rand.to_s[3..]
    parts2 = rand.to_s[3..]
    return "#{parts1[0..3]}-#{parts1[4..7]}-#{parts2[0..3]}-#{parts2[4..7]}"
  end
end