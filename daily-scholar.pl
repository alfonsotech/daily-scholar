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
use diagnostics;
# config.pm brings in the following variables:
#   %interests
#   %users
#   $mailUser
#   $mailPass
#   $smtpAddr
#   $mailHello
#   $mailPort
package config;

use LWP::Simple;               # For get();
use List::Util qw( shuffle );  # For the shuffle();
use IO::Socket::SSL qw( SSL_VERIFY_NONE );
use Net::SMTP::TLS;            # For emailing

# ============
# Var matey!
# ============
my $query;
my $email;
my $paper;
my $thisUID;

# ============
# Main
# ============

foreach my $user (config::%users) {

    $email = config::%users{$user};

    chooseInterest($user);
    getUID($query); 

    sendMail($email, $query, $paper, $thisUID);

    logEvents($user, $email, $query, $thisUID);

}


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
 
    my ( $user ) = @_;

    my @interests = config::%interests{$user};

    my @shuffled = shuffle @interests;
  
    $query = $shuffled[1];
  
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
    return ( $paper, $thisUID );

}


# ========================================
#    Name: sendMail
# Purpose: Sends the paper to the
#          specified email address
#  Params: $email, $query, $paper, $thisUID
# ========================================

sub sendMail {

    # my ( $email, $query, $paper, $thisUID ) = @_;

    print "Sending message\n";
    
    my $mailer = new Net::SMTP::TLS(
      $smtpAddr,
      Hello    => $mailHello,
      Port     => $mailPort,
      User     => $mailUser,
      Password => $mailPass
      );   
    $mailer->mail('');
    $mailer->to("$email");
    $mailer->data;
    $mailer->datasend("Todays Subject = " . $query);
    $mailer->datasend("\n\n");
    $mailer->datasend("$paper");
    $mailer->datasend("\n\n");
    $mailer->datasend("Read more: http://www.ncbi.nlm.nih.gov/pubmed/?term=" . $thisUID);
    $mailer->datasend("\n\n");
    $mailer->datasend("Don't be smart. Be curious.");
    $mailer->datasend("\n\n");
    $mailer->datasend("Love Always,\n");
    $mailer->datasend("Ben\n");
    $mailer->dataend;
    $mailer->quit;
    
    print "Message sent\n";

}

# I should finish sub this sometime...
sub logEvents {
   
    chomp (my $time = `perl -le "print scalar localtime"`);
    open (FILE, " >>results.log");
    print FILE "($time) $user ($email): \"$query\" | UID: $thisUID\n";
    close FILE;
}
