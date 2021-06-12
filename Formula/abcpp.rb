class Abcpp < Formula
  desc "ABC music notation preprocessor"
  homepage "https://abcplus.sourceforge.io/#abcpp"
  url "https://downloads.sourceforge.net/project/abcplus/abcpp/abcpp-1.4.5.tar.gz"
  sha256 "c45a7c3152233dd42970ac146f0e795cd1c6602bbcd1367abcf9cc65ae611183"
  license "GPL-2.0-or-later"

  def install
    system "make"
    bin.install "abcpp"
    doc.install "README"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test abcpp`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.

    # does it run at all?
    system "#{bin}/abcpp </dev/null"

    # now a real test:
    # abcpp my_music_nomidi.abp and abcpp my_music.abp should match
    # abcpp my_music_midi.abp and abcpp -MIDI my_music.abp should match

    (testpath/"my_music_nomidi.abp").write <<~EOF
      % my_music.abp
      %
      #define Index:  X:
      #define Title:  T:
      #define Meter:  M:
      #define Length: L:
      #define Tempo:  Q:
      #define Voice:  V:
      #define Key:    K:
      #define Style:  %%staves
      #define Duet    [1~2]
      #define !<(!  !crescendo(!
      #define !<)!  !crescendo)!
      #define !>(!  !diminuendo(!
      #define !>)!  !diminuendo)!
      #define !H!   !fermata!
      Index: 1
      Title: %abcpp% test
      Meter: 4/4
      Length: 1/4
      Tempo: "Allegro"
      Voice: 1 clef=treble name="Flute"
      Voice: 2 clef=treble name="Violin"
      Style: Duet
      Key: C
      %
      Voice: 1
      cdef|!<(!cde!<)!f|!>(!CDE!>)!F|!H!G4|
      Voice: 2
      ccee|ccgg        |g f e d     |!H!C4|
      %
      % End of file my_music.abp
    EOF

    (testpath/"my_music_midi.abp").write <<~EOF
      % my_music.abp
      %
      #define Index:  X:
      #define Title:  T:
      #define Meter:  M:
      #define Length: L:
      #define Tempo:  Q:
      #define Voice:  V:
      #define Key:    K:
      #define Style:  %%staves
      #define Duet    [1~2]
      #define !<(!  !crescendo(!
      #define !<)!  !crescendo)!
      #define !>(!  !diminuendo(!
      #define !>)!  !diminuendo)!
      #define !H!   !fermata!
      Index: 1
      Title: %abcpp% test
      Meter: 4/4
      Length: 1/4
      Tempo: 1/4 = 80
      Key: C
      %
      Voice: 1
      cdef|!<(!cde!<)!f|!>(!CDE!>)!F|!H!G4|
      Voice: 2
      ccee|ccgg        |g f e d     |!H!C4|
      %
      % End of file my_music.abp
    EOF

    (testpath/"my_defines.abp").write <<~EOF
      # my_defines.abp
      #
      #define Index:  X:
      #define Title:  T:
      #define Meter:  M:
      #define Length: L:
      #define Tempo:  Q:
      #define Voice:  V:
      #define Key:    K:
      #define Style:  %%staves
      #define Duet    [1~2]
      #define !<(!  !crescendo(!
      #define !<)!  !crescendo)!
      #define !>(!  !diminuendo(!
      #define !>)!  !diminuendo)!
      #define !H!   !fermata!
    EOF

    (testpath/"my_music.abp").write <<~EOF
      % my_music.abp
      %
      #
      #include my_defines.abp
      #
      Index: 1
      Title: %abcpp% test
      Meter: 4/4
      Length: 1/4
      #ifdef MIDI
      Tempo: 1/4 = 80
      #else
      Tempo: "Allegro"
      Voice: 1 clef=treble name="Flute"
      Voice: 2 clef=treble name="Violin"
      Style: Duet
      #endif
      Key: C
      %
      Voice: 1
      cdef|!<(!cde!<)!f|!>(!CDE!>)!F|!H!G4|
      Voice: 2
      ccee|ccgg        |g f e d     |!H!C4|
      %
      % End of file my_music.abp
    EOF

    system "#{bin}/abcpp", "my_music_nomidi.abp", "my_music_nomidi.a.abc"
    system "#{bin}/abcpp", "my_music.abp", "my_music_nomidi.b.abc"
    system "diff", "my_music_nomidi.a.abc", "my_music_nomidi.b.abc"

    system "#{bin}/abcpp", "my_music_midi.abp", "my_music_midi.a.abc"
    system "#{bin}/abcpp", "-MIDI", "my_music.abp", "my_music_midi.b.abc"
    system "diff", "my_music_midi.a.abc", "my_music_midi.b.abc"
  end
end
