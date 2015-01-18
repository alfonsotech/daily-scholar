#!/usr/bin/perl
#
# This is just a collection of variables meant to configure the
# main program script.
#

# ===============
# The people
# ===============

our %interests = (
    'Ben'    => ['genetics','synthetic biology','aging'],
    'Sima'   => ['physical therapy','exercise science','aging']
);

our %users = (
    'Ben'    => ['bensima@gmail.com'],
    'Sima'   => ['bsima@me.com']
);

# ===============
# Email settings
# ===============
our $mailUser    = 'blah';
our $mailPass    = 'blah';
our $smtpAddr    = 'smtp.gmail.com';
our $mailHello   = 'smtp.gmail.com';
our $mailPort    = 587;







# This line makes it a Perl module!
1;
