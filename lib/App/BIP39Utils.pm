package App::BIP39Utils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{gen_bip39_mnemonic_phrase} = {
    v => 1.1,
    summary => 'Generate BIP39 mnemonic phrase',
    args => {
        language => {
            summary => 'Pick which language wordlist to use',
            schema => ['str*', match=>qr/\A\w{2}(?:-\w+)?\z/],
            default => 'en',
            description => <<'_',

Will retrieve wordlist from `WordList::<LANG_CODE>::BIP39` Perl module.

For Chinese (simplified), use `zh-simplified`. For Chinese (traditional), use
`zh-traditional`.

_
        },
        length => {
            summary => 'Number of words to produce',
            schema => ['posint*', max=>128],
            default => 12,
        },
    },
};
sub gen_bip39_mnemonic_phrase {
    require Math::Random::Secure;

    my %args = @_;

    my ($langcode, $variant) = ($args{language} // 'en') =~ /\A(\w{2})(?:-(\w+))?\z/
        or return [400, "Invalid language '$args{language}', please specify a 2-digit language code"];
    my $mod = "WordList::".uc($langcode).($variant ? "::".ucfirst(lc($variant)) : "")."::BIP39";
    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;

    my @all_words = $mod->new->all_words;

    my @words;
    my $length = $args{length} // 12;
    for (1..$length) {
        my $word = $words[@words * Math::Random::Secure::rand()];
        redo if grep { $word eq $_ } @words;
        push @words, $word;
    }

    [200, "OK", join(" ", @words)];
}

1;
# ABSTRACT: Collection of CLI utilities related to BIP39

=head1 DESCRIPTION

This distribution provides the following command-line utilities related to
BIP39:

#INSERT_EXECS_LIST

Keywords: bitcoin, cryptocurrency, BIP, bitcoin improvement proposal, mnemonic
phrase.


=head1 SEE ALSO

L<https://en.bitcoin.it/wiki/Mnemonic_phrase>

L<https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki>

L<WordList::EN::BIP39> and BIP39 for the other languages in
C<WordList::*::BIP39>.

=cut
