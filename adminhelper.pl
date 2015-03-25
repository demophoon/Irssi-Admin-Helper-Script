use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '1.00';
%IRSSI = (
    authors     => 'Britt Gresham',
    contact     => 'britt@brittg.com',
    name        => 'Admin Helper',
    description => 'List hostmasks that a ban will cover before doing it' .
    license     => 'MIT',
);

my $last_mask = "";
my $last_channel = "";

sub get_matching_nicks {
    my ($data, $server) = @_;

    my @hostmasks = Irssi::active_win()->{active}->nicks();
    my @final_masks = ();
    foreach (@hostmasks) {
        my $current = $_;
        if ($server->mask_match_address($data, $current->{nick}, $current->{host})) {
            push @final_masks, $current;
        }
    }
    return @final_masks
}

sub get_matching_nicks_formatted {
    my ($data, $server) = @_;

    my @hostmasks = get_matching_nicks($data, $server);
    my @final_masks = ();
    foreach (@hostmasks) {
        my $current = $_;
        push @final_masks, $current->{nick} . "!" . $current->{host};
    }
    return @final_masks
}

sub list_masks {
    my ($data, $server, $witem) = @_;
    return unless $witem;
    # $witem (window item) may be undef.

    my $channel_name = Irssi::active_win()->{active}->{name};
    $data =~ s/^\s+|\s+$//g;
    $last_mask = $data;
    $last_channel = $channel_name;

    my @final_masks = get_matching_nicks_formatted($data, $server);
    my $arrsize = scalar(@final_masks);
    $witem->print("Mask matches $arrsize hosts: " . join(', ', @final_masks));
}

sub action_masks {
    my ($data, $server, $witem) = @_;
    my $channel_name = Irssi::active_win()->{active}->{name};

    # State/input validation
    my $err_msg = "";
    if ($witem->{chanop} == 0) {
        $err_msg = "You do not have OP in $channel_name";
    }
    if ($last_channel ne $channel_name) {
        $err_msg = "Run '/masks <host_mask>' in the channel before running '/action_masks'.";
    }
    if ($last_mask eq "") {
        $err_msg = "Run '/masks <host_mask>' in the channel before running '/action_masks'.";
    }
    if ($err_msg ne "") {
        $witem->print($err_msg);
        return;
    }

    my @actions = split(' ', $data);
    my $action = shift(@actions);
    my $msg = join(" ", @actions);
    my $cmd = "";

    if ($action eq "VOICE") {
        $cmd = "voice $last_mask"
    } elsif ($action eq "OP") {
        $cmd = "op $last_mask"
    } elsif ($action eq "DEVOICE") {
        $cmd = "devoice $last_mask"
    } elsif ($action eq "DEOP") {
        $cmd = "deop $last_mask"
    } elsif ($action eq "UNBAN") {
        $cmd = "unban $last_mask"
    } elsif ($action eq "KICK") {
        my @final_masks = get_matching_nicks($last_mask, $server);
        my $arrsize = scalar(@final_masks);
        if ($arrsize != 1) {
            $witem->print("Kick only works with one matching nick.");
            return;
        }
        my $kick_nick = pop @final_masks;
        $kick_nick = $kick_nick->{nick};
        $cmd = "kick $kick_nick $msg";
    } elsif ($action eq "BAN") {
        $cmd = "ban $last_mask"
    } else {
        $witem->print("Invalid Command.");
        return;
    }

    # Run the command
    if ($cmd ne "") {
        $witem->print($cmd);
        $witem->command($cmd);
    }
};

Irssi::command_bind masks => \&list_masks;
Irssi::command_bind masks_action => \&action_masks;
