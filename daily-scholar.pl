#!/usr/bin/perl
#
###################################################################
#   Title: Daily Scholar
# Purpose: To download a medical paper on a topic pre-selected
#          from my list of interests, and emailed to me on my
#          iPhone. The paper will be formatted in HTML or plain
#          text, and organized how I like it*, with figures either
#          embedded in the HTML or attached to the email.
#          *i.e., only Abstract, Intro, and Conclusions/Results
###################################################################
#
#

use strict;
use warnings;
# use diagnostics;

use LWP::Simple;               # For get();
use List::Util qw( shuffle );  # For the shuffle();
use IO::Socket::SSL qw( SSL_VERIFY_NONE );
use Net::SMTP::TLS;            # For emailing

# 1) Open a file of interests
# 2) Randomly choose a line and copy the phrase
# 3) Build an Eutils query from that phrase
# 4) Download the 10 most cited papers (UID's) from the search
# 5) Choose a random paper UID
# 6) Format the paper in text/HTML
# 7) Email the paper to bsima@me.com

# ============
# Variables
# ============
my $interests = './interests.txt';
my $query;
my $thisUID;
my $paper;
my $mail_user;
my $mail_pass;
my $email = 'bsima@me.com';


# ============
# Main
# ============

chooseInterest();
getUID($query);

# Get the creds for mailer
open(FILE,"config.txt");
my @config = <FILE>;
close FILE;
$mail_user = "$config[0]";
chomp($mail_user);
$mail_pass = "$config[1]";
chomp($mail_pass);

sendMail($paper, $email);


# ============
# Subroutines
# ============

# ========================================
#    Name: chooseInterest
# Purpose: Opens $interests and randomly
#          chooses a topic
#  Params: Not sure yet
# ========================================

sub chooseInterest {
  open(FILE,$interests) || die "Couldn't open interests file!";
  my @interest = <FILE>;
  close FILE;
  
  my @shuffled = shuffle @interest;
  
  $query = $shuffled[1];
  
  print $query;
  return $query;
  
}


# ========================================
#    Name: getUID
# Purpose: Gets the UID's of the top 10
#          cited papers from Pubmed
#  Params: query
# ========================================

sub getUID {
  
  # First, build the Eutils query
  my $utils = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils'; # Base URL for searches
  my $db = 'pubmed'; # Default to PubMed database; this may be changed.
  my $retmax = 10; # Get 10 results from Eutils
  
  my $esearch = $utils . '/esearch.fcgi?db=' . $db . '&retmax=' . $retmax . '&term=';
  
  my $esearch_result = get( $esearch . $query ); # Downloads the XML
  
  # Second, extract the UIDs and shuffle
  my @matches = $esearch_result =~ m(<Id>(.*)</Id>)g;  # print "$_\n" for @matches;
  my @shuffled = shuffle @matches;
  
  # Third, pick one of the UIDs to use for the Efetch
  $thisUID = $shuffled[1];
  
  # Fourth, fetch the paper
  my $report = 'abstract';    # We only want to fetch the abstract
  my $mode   = 'text';        # We want a text output, not XML

  my $efetch = $utils . '/efetch.fcgi?db=' . $db . '&rettype=' . $report . '&retmode=' . $mode . '&id=' . $thisUID;
  my $efetch_result = get($efetch);
  
  $paper = $efetch_result;
  
  # print $paper;
  return $paper;

}


# ========================================
#    Name: sendMail
# Purpose: Sends the paper to the
#          specified email address
#  Params: paper, email
# ========================================

sub sendMail {
  
  print "Sending message\n";

  my $mailer = new Net::SMTP::TLS(
    'smtp.gmail.com',
    Hello    =>      'smtp.gmail.com',
    Port     =>      587,
    User     =>      $mail_user,     # User (does not need @gmail.com)
    Password =>      $mail_pass);    # Password goes here in plaintext
  $mailer->mail('');
  $mailer->to("$email");
  $mailer->data;
  $mailer->datasend("Todays Subject = " . $query);
  $mailer->datasend("\n\n");
  $mailer->datasend("$paper");
  $mailer->datasend("\n\n");
  $mailer->datasend("Read more: http://www.ncbi.nlm.nih.gov/pubmed/?term=" . $thisUID);
  $mailer->dataend;
  $mailer->quit;
  
  print "Message sent\n";

}

# I should finish sub this sometime...
# sub logEvents {
#   chomp (my $time = `perl -le "print scalar localtime"`);
#   open (FILE, " >> results.log");
#   print FILE "($time) $_[0]: \"$paper\"\n";
#   close FILE;
# }