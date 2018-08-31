class Enigma::Setup < LuckyCli::Task
  banner "Setup encrypted configuration with Engima"

  # TODO: Generate a super secret key
  def call(key : String = generate_key, io : IO = STDOUT)
    puts "Setting up encrypted configuration with Engima"
    run "git config --local lucky.enigma.key #{key}", io
    # TODO Only add top line
    # config/encrypted/* filter=crypt diff=crypt
    File.write ".gitattributes", <<-TEXT
    config/encrypted/* filter=enigma diff=enigma
    TEXT

    # Link to CLI
    # https://stackoverflow.com/questions/35305503/adding-filter-entries-to-the-git-config-file

    # From transcrypt:
    # [filter "crypt"]
    #   clean = \"$(git rev-parse --git-common-dir)\"/crypt/clean %f
    #   smudge = \"$(git rev-parse --git-common-dir)\"/crypt/smudge
    #   required = true
    # [diff "crypt"]
    #   textconv = \"$(git rev-parse --git-common-dir)\"/crypt/textconv
    #   cachetextconv = true
    #   binary = true

    # git config filter.enigma.clean '"$(git rev-parse --git-common-dir)"/crypt/clean %f'
    # git config filter.enigma.smudge '"$(git rev-parse --git-common-dir)"/crypt/smudge'
    # git config diff.enigma.textconv '"$(git rev-parse --git-common-dir)"/crypt/textconv'
    # git config filter.enigma.required 'true'
    # git config diff.enigma.cachetextconv 'true'
    # git config diff.enigma.binary 'true'
  end

  private def run(command, io)
    Process.run(command, shell: true, output: io, error: STDERR)
  end

  private def generate_key : String
    Random::Secure.base64(32)
  end
end