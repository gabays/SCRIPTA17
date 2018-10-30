#!/usr/bin/perl

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
use utf8;
use strict;

my $flt_lexicon_file = shift || die "Please provide a lexicon as an argument to the script";
my $rules_file = shift || die "Please provide a rules file";

my %lex;
open LEX, "<$flt_lexicon_file" || die "Could not open lexicon file '$flt_lexicon_file': $!";
binmode LEX, ":utf8";
my $l = 0;
while (<LEX>) {
  chomp;
  $l++;
  /^([^\t]+)\t[^\t]+\t[^\t]+(?:\t.*)?$/ || die "Incorrect format line $l (line: $_). Lexicon format is the following: one entry per line, each line formatted as follows: form<tab>POS<tab>lemma\n";
  $lex{$1} = $1;
}
delete($lex{ie});
delete($lex{"&"});
delete($lex{"verité"});
delete($lex{"asses"});

open RULES, "<$rules_file" || die "Could not open rules file '$rules_file': $!";
binmode RULES, ":utf8";
$l = 0;
my @rule;
while (<RULES>) {
  chomp;
  $l++;
  /^([^\t]+)\t([^\t]*)\t([MNA])$/ || die "Invalid rule line $l\n";
  $rule[$l]{in} = $1;
  $rule[$l]{out} = $2;
  $rule[$l]{label} = $3;
}
delete($lex{ie});


my (%count, $n_mod, $n_tot);
while (<>) {
  chomp;
  s/ / /g;
  s/_/ /g;
  if (/^(\s*<lb[^<>]*\/>)(.*)$/) {
    print $1;
    my $content = $2;
    while ($content =~ s/(<[^<>]*) /$1 /g) {}
    $content =~ s/&amp;/&/g;
    my @tokens = split / /, $content;
    my @modtokens;
    for (@tokens)  {
      if (/^((?:<[^<>]+>)?\p{Punct}*)(.+?)(\p{Punct}*(?:<[^<>]+>)?)$/) {
	my ($before, $w, $after) = ($1, $2, $3);
	$n_tot++;
	if ($w =~ /[<>]/) {
	  push @modtokens, $_;	  
	} else {
	  my $r = 0;
	  my %mod_w;
	  $mod_w{$w} = "";
	  while (unknown_words(\%mod_w)) {
	    $r++;
	    for my $s (keys %mod_w) {
	      next unless $s =~ /$rule[$r]{in}/;
	      my $cur_label = $mod_w{$s};
	      my $cur_weight = length($cur_label);
	      my $pref = "";
	      while ($s =~ s/^(.*?)($rule[$r]{in})(.*)$/$3/) {
		my $mod_w = $pref.$1.$rule[$r]{out}.$3;
		if (!defined($mod_w{$mod_w}) || length($mod_w{$mod_w}) > $cur_weight+1) {
		  $mod_w{$mod_w} = $cur_label.$rule[$r]{label};
		}
		$pref = $1.$2;
	      }
	    }
	    last if $r == $#rule;
	  }
	  if (unknown_words(\%mod_w)) {
	    push @modtokens, $before."<w unknown=\"1\">".$w."</w>".$after;
	  } else {
	    my $mod_w = best_known_sequence(\%mod_w);
	    if ($w eq $mod_w) {
	      push @modtokens, $before.$mod_w.$after;
	    } else {
	      push @modtokens, $before."<w source=\"$w\" label=\"$mod_w{$mod_w}\">".$mod_w."</w>".$after;
	      for (split //, $mod_w{$mod_w}) {
		$count{$_}++;
		$count{__ALL__}++;
	      }
	      $n_mod++;
	    }
	  }
	}
      } else {
	push @modtokens, $_;
      }
    }
    $content = join " ", @modtokens;
    $content =~ s/&/&amp;/g;
    print "$content\n";
  } else {
    print "$_\n";
  }
}

print STDERR "$n_mod (séquences de) mots modernisés sur un total de $n_tot\n";
print STDERR "$count{__ALL__} règles appliquées, parmi lesquelles:\n";
print STDERR " - $count{A} ont corrigé des graphies archaisantes\n";
print STDERR " - $count{M} ont corrigé des graphies modernisantes\n";
print STDERR "Pourcentage de mots modernisés : ".(int(1000*$n_mod/$n_tot+0.49999)/10)."\%\n";
print STDERR "Nombre moyen de règles appliquées par mot modernisé : ".(int(1000*$count{__ALL__}/$n_mod+0.49999)/10)."\%\n";
print STDERR "Nombre moyen de règles appliquées par mot : ".(int(1000*$count{__ALL__}/$n_tot+0.49999)/10)."\%\n";
print STDERR "Équilibre modernisant (positif) vs. archaisant (négatif), normalisé par le nombre de règles appliquées : ".(int(1000*(($count{M}-$count{A})/$count{__ALL__})+0.49999)/10)."\%\n";

sub unknown_words {
  my $h = shift;
  my $ret_val = 1;
  for my $s (keys %$h) {
    my $unknown_words_in_s = 0;
    for (split /(?: |(?<='))/, $s) {
      unless (defined $lex{$_}) {
	$unknown_words_in_s = 1;
	last;
      }
    }
    if ($unknown_words_in_s == 0) {
      $ret_val = 0;
      last;
    }
  }
  return $ret_val;
}

sub best_known_sequence {
  my $h = shift;
  my $ret_val;
  my $cur_best_score = 100000;
  for my $s (keys %$h) {
    my $unknown_words_in_s = 0;
    for (split /(?: |(?<='))/, $s) {
      unless (defined $lex{$_}) {
	$unknown_words_in_s = 1;
	last;
      }
    }
    if ($unknown_words_in_s == 0) {
      if (length($h->{$s}) < $cur_best_score) {
	$ret_val = $s;
	$cur_best_score = length($h->{$s});
      }
    }
  }
  die if $ret_val eq "";
  return $ret_val;
}
